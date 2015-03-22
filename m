From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v2 2/5] mpls: Remove incorrect PHP comment
Date: Sun, 22 Mar 2015 14:12:59 -0500
Message-ID: <87fv8wals4.fsf@x220.int.ebiederm.org>
References: <1426800772-22378-1-git-send-email-rshearma@brocade.com>
	<1426866170-28739-1-git-send-email-rshearma@brocade.com>
	<1426866170-28739-3-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:51726 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbbCVTQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 15:16:48 -0400
In-Reply-To: <1426866170-28739-3-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Fri, 20 Mar 2015 15:42:47 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> Popping the last label on the stack does not necessarily imply
> performing penultimate hop popping. There is no reason why this
> couldn't be the last hop in the network, so remove the comment.

So this change I will disagree with.

What the code implements is Penultimate hop popping.  Even if you send
the packets over loopback that is what the code is doing.

This is relevant because I think the code may actually be wrong in the
local reception case.  By preforming penultimate hop popping and
receving the code on loopback I think this code allows bypassing
iptables rules that apply to incoming ip packets.  Certainly there is a
loss of information as to which hardware interface the packet came in on
that it may be desirable to correct.

Eric


> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  net/mpls/af_mpls.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 0d6763a..bf3459a 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -199,7 +199,6 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>  	skb->protocol = htons(ETH_P_MPLS_UC);
>  
>  	if (unlikely(!new_header_size && dec.bos)) {
> -		/* Penultimate hop popping */
>  		if (!mpls_egress(rt, skb, dec))
>  			goto drop;
>  	} else {
