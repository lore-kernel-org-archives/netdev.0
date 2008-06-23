From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 10/25] netns ct: fix ip_route_me_harder() for REEJCT,
 NAT	et al
Date: Mon, 23 Jun 2008 12:40:35 +0200
Message-ID: <485F7DA3.2010700@trash.net>
References: <20080622010920.GK5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080622010920.GK5392@martell.zuzino.mipt.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> ip_route_me_harder() is called on output codepaths:
> 1) IPVS: honestly, not sure, it can be called during forwarding
> 2) IPv4 REJECT: refreshing comment re skb->dst is valid
> 	and assigment of skb->dst right before call :^)
> 3) NAT: called in LOCAL_OUT hook
> 4) iptable_mangle: LOCAL_OUT hook
> 5) nf_ip_reroute(): LOCAL_OUT hook (no clue about queueing packets to luserspace)

skb->dst->dev seems OK in all these cases.

> P.S.: IPv6 version is also called by mangling code on input, what's the story
>       behind this discrepancy?

That looks wrong, I think the reason for this bug is that
IPv6 originally didn't support routing rules, so the call
was #ifdef 0'ed, then enabled without checking the hooks.
I'll queue up a fix.

