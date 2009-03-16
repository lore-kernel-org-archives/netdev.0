From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCHv2] netns: oops in ip_frag_reasm incrementing stats
Date: Mon, 16 Mar 2009 22:05:41 +0100
Message-ID: <49BEBF25.70008@gmail.com>
References: <49BA87F4.1090709@dti2.net> <49BA8B65.2060408@dti2.net> <49BE4192.7090706@dti2.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:37138 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669AbZCPVHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 17:07:07 -0400
Received: by fxm24 with SMTP id 24so3667696fxm.37
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2009 14:07:03 -0700 (PDT)
In-Reply-To: <49BE4192.7090706@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jorge Boncompte [DTI2] wrote, On 03/16/2009 01:09 PM:

> dev can be NULL on ip_frag_reasm for skb's coming from RAW sockets.
> 
> Quagga's OSPFD sends fragmented packets on a RAW socket, when netfilter
> conntrack reassembles them on the OUTPUT path you hit this code path.
> 
> Changes from v1:
>    - Fixed description
> 
> Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
> ---
> net/ipv4/ip_fragment.c |   14 +++++++-------
> 1 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> index 6659ac0..8f150d5 100644
> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c

...

> -static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
> +static int ip_frag_reasm(struct net *net, struct ipq *qp, struct sk_buff *prev,
> 			 struct net_device *dev)
> {
> 	struct iphdr *iph;
> @@ -548,7 +548,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
> 	iph = ip_hdr(head);
> 	iph->frag_off = 0;
> 	iph->tot_len = htons(len);
> -	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMOKS);
> +	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);


I didn't check this but isn't something like this possible here too?:

static inline int ip_frag_too_far(struct ipq *qp)
{
	...
        net = container_of(qp->q.net, struct net, ipv4.frags);
        IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);

Jarek P.
