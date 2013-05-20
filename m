From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: check skb_transport_header_was_set() in
 qdisc_pkt_len_init()
Date: Mon, 20 May 2013 11:58:43 -0700
Message-ID: <1369076323.3301.200.camel@edumazet-glaptop>
References: <1369075650-21005-1-git-send-email-mjrosato@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33359 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756512Ab3ETS6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 14:58:44 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp6so5930066pab.21
        for <netdev@vger.kernel.org>; Mon, 20 May 2013 11:58:44 -0700 (PDT)
In-Reply-To: <1369075650-21005-1-git-send-email-mjrosato@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-05-20 at 14:47 -0400, Matthew Rosato wrote:
> commit 1def9238d4aa2 (net_sched: more precise pkt_len computation) does
> not check to see if skb_transport_header is valid prior to using it in
> qdisc_pkt_len_init(), which can lead to a kernel panic if
> skb_transport_header is not valid but gso_size is nonzero.  This patch
> adds a check for skb_transport_header_was_set().
> 
> I managed to hit this scenario by driving a burst of traffic from a
> qemu guest through a macvtap interface, causing a panic in the host kernel.
> 
> Signed-off-by: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
> ---
>  net/core/dev.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index fc1e289..5d0d3af 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2596,7 +2596,7 @@ static void qdisc_pkt_len_init(struct sk_buff *skb)
>  	/* To get more precise estimation of bytes sent on wire,
>  	 * we add to pkt_len the headers size of all segments
>  	 */
> -	if (shinfo->gso_size)  {
> +	if (shinfo->gso_size && skb_transport_header_was_set(skb))  {
>  		unsigned int hdr_len;
>  		u16 gso_segs = shinfo->gso_segs;
>  

Have you tried a recent kernel ?

I believe this was already discussed.

Please fix macvtap instead if its still buggy.
