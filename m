From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] net: Remove a noisy printk
Date: Tue, 16 Dec 2008 20:59:05 +0100 (CET)
Message-ID: <alpine.DEB.2.00.0812162044460.5854@blackhole.kfki.hu>
References: <1229033625-30825-1-git-send-email-ajax@redhat.com> <20081211.203243.124017657.davem@davemloft.net> <alpine.LNX.1.10.0812132310080.27276@fbirervta.pbzchgretzou.qr> <alpine.DEB.2.00.0812141745550.2447@blackhole.kfki.hu>
 <20081214200353.GA2994@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jan Engelhardt <jengelh@medozas.de>,
	David Miller <davem@davemloft.net>, ajax@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Dave Jones <davej@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081214200353.GA2994@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 14 Dec 2008, Dave Jones wrote:

> On Sun, Dec 14, 2008 at 06:09:17PM +0100, Jozsef Kadlecsik wrote:
> 
>  > > >> @@ -147,8 +147,6 @@ static unsigned int ipv4_conntrack_local(unsigned int hooknum,
>  > > >>  	/* root is playing with raw sockets. */
>  > > >>  	if (skb->len < sizeof(struct iphdr) ||
>  > > >>  	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
>  > > >> -		if (net_ratelimit())
>  > > >> -			printk("ipt_hook: happy cracking.\n");
>  > > >>  		return NF_ACCEPT;
>  > > >>  	}
>  > > >>  	return nf_conntrack_in(dev_net(out), PF_INET, hooknum, skb);
>  > > 
>  > > I think this change is ok.
>  > 
>  > In a >normal< system one usually does not use raw sockets. So if a root 
>  > process do use raw socket, at least netfilter sends a notification and 
>  > there's a chance that someone take notice it by checking the kernel logs.
> 
> 'normal' systems are irrelevant here. This message is triggerable remotely.
> Even though it's ratelimited, anyone can flood another boxes logs by
> sending enough packets.

The packets in question are shorter than the IP header. How would those be 
delivered to the host? On the LAN it might be possible to forge such 
packets with proper HW address and be delivered. But wouldn't the network 
card or the stack itself throw away the packets??
 
> The message is also utterly useless. What kind of action would you take
> to a few gigabytes of "ipt_hook: happy cracking.\n" ?
> There's no IP address logged, or any other useful information.

As the packet is shorter than the IP header, what could be logged, besides 
the fact that something worth to investigate is happening?

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
