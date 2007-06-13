From: psr <pradeep.rautela@gmail.com>
Subject: Re: [KJ] [KJ PATCH] Replacing alloc_pages(gfp, 0) with alloc_page(gfp) in net/core/pktgen.c
Date: Wed, 13 Jun 2007 15:42:39 +0530
Message-ID: <a901b49a0706130312mba8a686m455b5cbf774cc159@mail.gmail.com>
References: <1181702562.2282.12.camel@shani-win>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, kernel-janitors@lists.osdl.org
To: "Shani Moideen" <shani.moideen@wipro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.237]:17153 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755491AbXFMKMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 06:12:40 -0400
Received: by nz-out-0506.google.com with SMTP id n1so155909nzf
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 03:12:40 -0700 (PDT)
In-Reply-To: <1181702562.2282.12.camel@shani-win>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/13/07, Shani Moideen <shani.moideen@wipro.com> wrote:
>
> Replacing alloc_pages(gfp,0) with alloc_page(gfp)
> in net/core/pktgen.c
>
> Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
> ----
>
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index b92a322..2600c7f 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -2414,7 +2414,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
>
>                 i = 0;
>                 while (datalen > 0) {
> -                       struct page *page = alloc_pages(GFP_KERNEL, 0);
> +                       struct page *page = alloc_page(GFP_KERNEL);

Does this makes any difference anyway? Both are same eventually?
What is the rational behind this? Can you please help me understanding this?

thanks
--pradeep
>                         skb_shinfo(skb)->frags[i].page = page;
>                         skb_shinfo(skb)->frags[i].page_offset = 0;
>                         skb_shinfo(skb)->frags[i].size =
> @@ -2762,7 +2762,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
>
>                 i = 0;
>                 while (datalen > 0) {
> -                       struct page *page = alloc_pages(GFP_KERNEL, 0);
> +                       struct page *page = alloc_page(GFP_KERNEL);
>                         skb_shinfo(skb)->frags[i].page = page;
>                         skb_shinfo(skb)->frags[i].page_offset = 0;
>                         skb_shinfo(skb)->frags[i].size =
>
> --
> Shani
> _______________________________________________
> Kernel-janitors mailing list
> Kernel-janitors@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/kernel-janitors
>
