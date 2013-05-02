From: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: Regression in 3.9 caused by "bridge: respect RFC2863 operational
 state"
Date: Thu, 02 May 2013 02:53:59 +0200
Message-ID: <5181B927.5010407@openwrt.org>
References: <518166C5.4080904@openwrt.org> <CABPxzYLP53mnMXAicD33oX8TW77xnZziS=XBuVCy_u4H2oyLUw@mail.gmail.com> <CAOaVG179Rx_JfV99mbjWhwQTALb5gh+2_WVFWDSbngA0qkzoGw@mail.gmail.com> <518183C8.8050606@openwrt.org> <20130501154904.0ea31991@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Krishna Chaitanya <chaitanya.mgit-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sebastian Gottschall <s.gottschall-t37Kgv3TaIPQT0dZR+AlfA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130501154904.0ea31991-We1ePj4FEcvRI77zikRAJc56i+j3xesD0e7PPNI6Mm0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2013-05-02 12:49 AM, Stephen Hemminger wrote:
> On Wed, 01 May 2013 23:06:16 +0200
> Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org> wrote:
> 
>> On 2013-05-01 10:21 PM, Stephen Hemminger wrote:
>> > What about using AF_PACKET bound to underlying wireless device and the
>> > packet type. You can even use BPF to filter.
>> As far as I know, AF_PACKET only works when not binding it to the packet
>> type (otherwise it get stolen by the rx handler).
> 
> You can do AF_PACKET and it gets handle before rx_handler.
If I don't bind it to a protocol, it ends up in ptype_all, if I do, it
ends up in &ptype_base. ptype_all is processed before the rx_handler,
ptype_base is processed after the rx handler.
Hooking into ptype_all wastes tons of CPU cycles, hooking into
ptype_base does not solve the problem.

- Felix
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
