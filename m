From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH -next] xen-netback: fix some error return code
Date: Mon, 16 Dec 2013 13:13:13 +0000
Message-ID: <20131216131313.GE12582@zion.uk.xensource.com>
References: <CAPgLHd9aQQq-gLuNzGaYP2TSz=5Xk_GqgS=MSrAB7Tnn0nCydw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<yongjun_wei@trendmicro.com.cn>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:1277 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753466Ab3LPNNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 08:13:24 -0500
Content-Disposition: inline
In-Reply-To: <CAPgLHd9aQQq-gLuNzGaYP2TSz=5Xk_GqgS=MSrAB7Tnn0nCydw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 01:49:29PM +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return -EPROTO error code instead of 0(overwrite by maybe_pull_tail())
> if skb_partial_csum_set() return false.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/xen-netback/netback.c | 16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 800496b..b16daa7 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1108,8 +1108,10 @@ static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
>  			goto out;
>  
>  		if (!skb_partial_csum_set(skb, off,
> -					  offsetof(struct tcphdr, check)))
> +					  offsetof(struct tcphdr, check))) {
> +			err = -EPROTO;

Why is this needed? It is set to -EPROTO before the 'switch'.


Wei.
