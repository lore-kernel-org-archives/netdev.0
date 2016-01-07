From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] bpf: add skb_postpush_rcsum and fix
 dev_forward_skb occasions
Date: Thu, 7 Jan 2016 02:53:10 +0100
Message-ID: <568DC506.6020200@stressinduktion.org>
References: <02f04a0cd04748df932912bac36afeccc4ee7755.1452125392.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:59476 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751924AbcAGBxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 20:53:12 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 55BF920275
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 20:53:12 -0500 (EST)
In-Reply-To: <02f04a0cd04748df932912bac36afeccc4ee7755.1452125392.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07.01.2016 02:01, Daniel Borkmann wrote:
> +static inline void skb_postpush_rcsum(struct sk_buff *skb,
> +				      const void *start, unsigned int len)
> +{
> +	if (skb->ip_summed == CHECKSUM_COMPLETE)
> +		skb->csum = csum_add(skb->csum, csum_partial(start, len, 0));

skb->csum = csum_partial(start, len, skb->csum);

should work without calling carry-add twice, no?

Bye,
Hannes
