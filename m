From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] net: Remove a noisy printk
Date: Sun, 14 Dec 2008 21:15:20 +0100 (CET)
Message-ID: <alpine.DEB.2.00.0812142056520.2621@blackhole.kfki.hu>
References: <1229033625-30825-1-git-send-email-ajax@redhat.com> <20081211.203243.124017657.davem@davemloft.net> <alpine.LNX.1.10.0812132310080.27276@fbirervta.pbzchgretzou.qr> <alpine.DEB.2.00.0812141745550.2447@blackhole.kfki.hu>
 <alpine.LNX.1.10.0812141905490.10355@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, ajax@redhat.com,
	linux-kernel@vger.kernel.org, davej@redhat.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp0.kfki.hu ([148.6.0.25]:47155 "EHLO smtp0.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353AbYLNUPW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Dec 2008 15:15:22 -0500
In-Reply-To: <alpine.LNX.1.10.0812141905490.10355@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 14 Dec 2008, Jan Engelhardt wrote:

> On Sunday 2008-12-14 18:09, Jozsef Kadlecsik wrote:
> >> 
> >> >> @@ -147,8 +147,6 @@ static unsigned int ipv4_conntrack_local(unsigned int hooknum,
> >> >>  	/* root is playing with raw sockets. */
> >> >>  	if (skb->len < sizeof(struct iphdr) ||
> >> >>  	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
> >> >> -		if (net_ratelimit())
> >> >> -			printk("ipt_hook: happy cracking.\n");
> >> >>  		return NF_ACCEPT;
> >> >>  	}
> >> >>  	return nf_conntrack_in(dev_net(out), PF_INET, hooknum, skb);
> >> 
> >> I think this change is ok.
> >
> >In a >normal< system one usually does not use raw sockets. So if a root 
> >process do use raw socket, at least netfilter sends a notification and 
> >there's a chance that someone take notice it by checking the kernel logs.
> >[...]
> >But should we remove them due to nuisances on >test< systems?
> >
> >Rather make it a kernel compile option but do not remove.
> 
> This warning is in the conntrack calling code. Iff you play with
> raw sockets and do something wrong, the generic network code
> should barf IMHO, not nf_conntrack, and not [nf_conntrack_ipv4 only].

It is not about doing something wrong at using raw sockets - it's about 
using raw sockets.

I'm not quite convinced the generic network code should warn about raw 
sockets. I believe it belongs to the security-related subsystems - 
netfilter and (or) the security frameworks. [But as netfilter is much more 
widely used, the 'or' is just theoretical.)

But back to netfilter: this is more than strange. The logging is already 
removed from iptable_filter|mangle.c - and left in 
ip6table_filter|mangle.c. The only place in the IPv4 path where the 
checking happens is in nf_conntrack_l3proto_ipv4.c. IPv6 conntrack does
it as well, but uses another message text:

        if (skb->len < sizeof(struct ipv6hdr)) {
                if (net_ratelimit())
                        printk("ipv6_conntrack_local: packet too short\n");

[ISIC should check IPv6 too ;-).]

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
