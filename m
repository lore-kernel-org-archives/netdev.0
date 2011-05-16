From: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: several packets in a single buffer in Rx
Date: Mon, 16 May 2011 12:41:07 +0300
Message-ID: <BANLkTimkgtQL1A2A3iAP-UYK2KdDvPmY3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Guy, Wey-Yi" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, guy.cohen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I am trying to enable a HW feature on a wireless NIC that allows the
HW to put several packets in the same Rx buffer coming from the NIC.
This can save interrupts and traffic on the bus.
Today, the driver allocates pages in which the PCI-e device puts its
data. Then we create an skb and add a fragment that points to the
beginning of the page. The offset of the fragment is set to the offset
of the first byte of the mac header within the buffer. There is only
one packet per page / buffer.

I would like to be able to deliver the same page several times to the
stack without having the stack consume it before the last time I
deliver it.
Of course I would like to avoid cloning it.

I tried to look at shinfo->nr_frags but this looks more like a sgl
related variable
GRO doesn't seem to be related either since as far as I understood, it
is relevant for packets after 802.11 to 802.3 translation.


FWIW: I am talking about Intel's wireless device although I don't
think this fact matters

Thanks

Emmanuel Grumbach
egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
