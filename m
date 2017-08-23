From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH][V2][netdev-next] gre: remove duplicated assignment of iph
Date: Wed, 23 Aug 2017 15:26:19 +0300
Message-ID: <6b9bc0fa-753f-5f85-d63a-dced94aa52cd@cumulusnetworks.com>
References: <20170823115948.19884-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        William Tu <u9012063@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36836 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753902AbdHWM0X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 08:26:23 -0400
Received: by mail-wm0-f54.google.com with SMTP id z132so14508809wmg.1
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 05:26:22 -0700 (PDT)
In-Reply-To: <20170823115948.19884-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/08/17 14:59, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> iph is being assigned the same value twice; remove the redundant
> first assignment. (Thanks to Nikolay Aleksandrov for pointing out
> that the first asssignment should be removed and not the second)
> 
> Fixes warning:
> net/ipv4/ip_gre.c:265:2: warning: Value stored to 'iph' is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/ipv4/ip_gre.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 6e8a62289e03..161326f7f10b 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -262,7 +262,6 @@ static int erspan_rcv(struct sk_buff *skb, struct tnl_ptk_info *tpi,
>  	int len;
>  
>  	itn = net_generic(net, erspan_net_id);
> -	iph = ip_hdr(skb);
>  	len = gre_hdr_len + sizeof(*ershdr);
>  
>  	if (unlikely(!pskb_may_pull(skb, len)))
> 

LGTM,

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
