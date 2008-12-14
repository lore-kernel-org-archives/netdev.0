From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] net: Remove a noisy printk
Date: Sun, 14 Dec 2008 19:06:56 +0100 (CET)
Message-ID: <alpine.LNX.1.10.0812141905490.10355@fbirervta.pbzchgretzou.qr>
References: <1229033625-30825-1-git-send-email-ajax@redhat.com> <20081211.203243.124017657.davem@davemloft.net> <alpine.LNX.1.10.0812132310080.27276@fbirervta.pbzchgretzou.qr> <alpine.DEB.2.00.0812141745550.2447@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, ajax@redhat.com,
	linux-kernel@vger.kernel.org, davej@redhat.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:60656 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbYLNSG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 13:06:59 -0500
In-Reply-To: <alpine.DEB.2.00.0812141745550.2447@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sunday 2008-12-14 18:09, Jozsef Kadlecsik wrote:
>> 
>> >> @@ -147,8 +147,6 @@ static unsigned int ipv4_conntrack_local(unsigned int hooknum,
>> >>  	/* root is playing with raw sockets. */
>> >>  	if (skb->len < sizeof(struct iphdr) ||
>> >>  	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
>> >> -		if (net_ratelimit())
>> >> -			printk("ipt_hook: happy cracking.\n");
>> >>  		return NF_ACCEPT;
>> >>  	}
>> >>  	return nf_conntrack_in(dev_net(out), PF_INET, hooknum, skb);
>> 
>> I think this change is ok.
>
>In a >normal< system one usually does not use raw sockets. So if a root 
>process do use raw socket, at least netfilter sends a notification and 
>there's a chance that someone take notice it by checking the kernel logs.
>[...]
>But should we remove them due to nuisances on >test< systems?
>
>Rather make it a kernel compile option but do not remove.

This warning is in the conntrack calling code. Iff you play with
raw sockets and do something wrong, the generic network code
should barf IMHO, not nf_conntrack, and not [nf_conntrack_ipv4 only].
