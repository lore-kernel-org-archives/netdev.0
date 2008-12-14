From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] net: Remove a noisy printk
Date: Sun, 14 Dec 2008 18:09:17 +0100 (CET)
Message-ID: <alpine.DEB.2.00.0812141745550.2447@blackhole.kfki.hu>
References: <1229033625-30825-1-git-send-email-ajax@redhat.com> <20081211.203243.124017657.davem@davemloft.net> <alpine.LNX.1.10.0812132310080.27276@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, ajax@redhat.com,
	linux-kernel@vger.kernel.org, davej@redhat.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.1.10.0812132310080.27276@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 13 Dec 2008, Jan Engelhardt wrote:

> On Friday 2008-12-12 05:32, David Miller wrote:
> >From: Adam Jackson <ajax@redhat.com>
> >Date: Thu, 11 Dec 2008 17:13:42 -0500
> >
> >> From: Dave Jones <davej@redhat.com>
> >> 
> >> These messages are trivial to trigger when running stress tests
> >> like isic, and add no real value.
> >> 
> >> Signed-off-by: Dave Jones <davej@redhat.com>
> >> Signed-off-by: Adam Jackson <ajax@redhat.com>
> >
> >If you don't send this to the netfilter developers nor the networking
> >developers, noboby knowledgable can even look at this patch.
> 
> (For the archive, it's not the Internation Student Identity Card)
> http://www.packetfactory.net/Projects/ISIC/ :
> 
> ?ISIC is a suite of utilities to exercise the stability of an IP
> Stack and its component stacks (TCP, UDP, ICMP et. al.) It generates
> piles of pseudo random packets of the target protocol.?
> 
> >> @@ -147,8 +147,6 @@ static unsigned int ipv4_conntrack_local(unsigned int hooknum,
> >>  	/* root is playing with raw sockets. */
> >>  	if (skb->len < sizeof(struct iphdr) ||
> >>  	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
> >> -		if (net_ratelimit())
> >> -			printk("ipt_hook: happy cracking.\n");
> >>  		return NF_ACCEPT;
> >>  	}
> >>  	return nf_conntrack_in(dev_net(out), PF_INET, hooknum, skb);
> 
> I think this change is ok.

In a >normal< system one usually does not use raw sockets. So if a root 
process do use raw socket, at least netfilter sends a notification and 
there's a chance that someone take notice it by checking the kernel logs.

Yes, if the machine is compromized then the logs can be tampered, if 
netfilter is compiled as a module, the module can be replaced by another 
one, and so on. A careful cracker can take care of all the alarms, trip 
wires. But should we remove them due to nuisances on >test< systems?

Rather make it a kernel compile option but do not remove.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
