From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: future developments of usbnet
Date: Wed, 11 May 2011 19:37:47 +0200
Message-ID: <201105111937.47448.oliver@neukum.org>
References: <BANLkTi=AGQyvG58n9FG2Axbz7Ue8a6E3kg@mail.gmail.com> <Pine.LNX.4.44L0.1105091130440.2002-100000@iolanthe.rowland.org> <20110509084649.127ec0da@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110509084649.127ec0da@nehalam>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Montag, 9. Mai 2011, 17:46:49 schrieb Stephen Hemminger:
> On Mon, 9 May 2011 11:31:16 -0400 (EDT)
> Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org> wrote:

> > How do other network drivers handle this problem?  Can the same 
> > strategy be used?
> > 
> > Alan Stern
> 
> Most Ethernet drivers have a fixed size receive ring and pass preallocated
> memory (skb's or pages) for the hardware to fill in. When NAPI poll is run
> it refills the ring and passes the data up to netif_receive_skb. NAPI allows
> the poll routine to process a limited number of packets (weight) and after
> that the poll loop exits and gets rerun by soft interrupt.  If data is
> arriving faster than the kernel can process, eventually the receive ring
> passed to hardware gets exhausted and the hardware drops packets.

How is the frequency NAPI uses to poll determined? We could abuse
this and resubmit the rx URBs only at poll time, but this feels dirty,
because we would still leave interrupts enabled.

Is there no other driver which faces this problem?

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
