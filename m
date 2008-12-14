From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] net: Remove a noisy printk
Date: Sun, 14 Dec 2008 15:03:53 -0500
Message-ID: <20081214200353.GA2994@redhat.com>
References: <1229033625-30825-1-git-send-email-ajax@redhat.com> <20081211.203243.124017657.davem@davemloft.net> <alpine.LNX.1.10.0812132310080.27276@fbirervta.pbzchgretzou.qr> <alpine.DEB.2.00.0812141745550.2447@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@medozas.de>,
	David Miller <davem@davemloft.net>, ajax@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0812141745550.2447@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 14, 2008 at 06:09:17PM +0100, Jozsef Kadlecsik wrote:

 > > >> @@ -147,8 +147,6 @@ static unsigned int ipv4_conntrack_local(unsigned int hooknum,
 > > >>  	/* root is playing with raw sockets. */
 > > >>  	if (skb->len < sizeof(struct iphdr) ||
 > > >>  	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
 > > >> -		if (net_ratelimit())
 > > >> -			printk("ipt_hook: happy cracking.\n");
 > > >>  		return NF_ACCEPT;
 > > >>  	}
 > > >>  	return nf_conntrack_in(dev_net(out), PF_INET, hooknum, skb);
 > > 
 > > I think this change is ok.
 > 
 > In a >normal< system one usually does not use raw sockets. So if a root 
 > process do use raw socket, at least netfilter sends a notification and 
 > there's a chance that someone take notice it by checking the kernel logs.

'normal' systems are irrelevant here. This message is triggerable remotely.
Even though it's ratelimited, anyone can flood another boxes logs by
sending enough packets.

The message is also utterly useless. What kind of action would you take
to a few gigabytes of "ipt_hook: happy cracking.\n" ?
There's no IP address logged, or any other useful information.

	Dave

-- 
http://www.codemonkey.org.uk
