From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] ip_gre: check packet length and mtu correctly
 in erspan_fb_xmit
Date: Thu, 5 Oct 2017 13:59:40 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD008AC42@AcuExch.aculab.com>
References: <1507162445-18540-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Xin Long <lucien.xin@gmail.com>
To: 'William Tu' <u9012063@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:61441 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751178AbdJEN7k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 09:59:40 -0400
In-Reply-To: <1507162445-18540-1-git-send-email-u9012063@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu
> Sent: 05 October 2017 01:14
> Similarly to early patch for erspan_xmit(), the ARPHDR_ETHER device
> is the length of the whole ether packet.  So skb->len should subtract
> the dev->hard_header_len.
> 
> Fixes: 1a66a836da63 ("gre: add collect_md mode to ERSPAN tunnel")
> Signed-off-by: William Tu <u9012063@gmail.com>
> Cc: Xin Long <lucien.xin@gmail.com>
> ---
>  net/ipv4/ip_gre.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index b279c325c7f6..10b21fe5b3a6 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -579,7 +579,7 @@ static void erspan_fb_xmit(struct sk_buff *skb, struct net_device *dev,
>  	if (gre_handle_offloads(skb, false))
>  		goto err_free_rt;
> 
> -	if (skb->len > dev->mtu) {
> +	if (skb->len - dev->hard_header_len > dev->mtu) {

Can you guarantee that skb->len > dev_hard_header_len?
It is probably safer to check skb->len > dev->hard_header_len + dev->mtu
since that addition isn't going to overflow.

>  		pskb_trim(skb, dev->mtu);
>  		truncate = true;

Is that pskb_trim() now truncating to the correct size?

	David
