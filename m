From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: Re: [PATCH] : Fix compilation warnings in net/802/fc.c
Date: Tue, 14 Oct 2008 21:35:04 +0200
Message-ID: <20081014193500.GA6502@joi>
References: <ea11fea30810141121w58e25b43x92d71ca800c5c96@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org
To: Manish Katiyar <mkatiyar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:29580 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbYJNThk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 15:37:40 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1037707ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 12:37:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ea11fea30810141121w58e25b43x92d71ca800c5c96@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2008 at 11:51:24PM +0530, Manish Katiyar wrote:
> [ I was not sure about which list is this appropriate, so putting
> kernel-janitors since this is cleanup]
Cc'ing netdev@vger

> 
> Below patch fixes the following warning during compilation.
> net/802/fc.c:85: warning: unused variable 'fch'
> 
> Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>
> 
> ---
>  net/802/fc.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/802/fc.c b/net/802/fc.c
> index cb3475e..7463109 100644
> --- a/net/802/fc.c
> +++ b/net/802/fc.c
> @@ -82,7 +82,9 @@ static int fc_header(struct sk_buff *skb, struct
> net_device *dev,
> 
>  static int fc_rebuild_header(struct sk_buff *skb)
>  {
> +#ifdef CONFIG_INET
>  	struct fch_hdr *fch=(struct fch_hdr *)skb->data;
> +#endif
>  	struct fcllc *fcllc=(struct fcllc *)(skb->data+sizeof(struct fch_hdr));
>  	if(fcllc->ethertype != htons(ETH_P_IP)) {
>  		printk("fc_rebuild_header: Don't know how to resolve type %04X
> addresses ?\n", ntohs(fcllc->ethertype));
> -- 

When !CONFIG_INET this function always returns 0 (and does not anything useful)
so it probably can be written as:

#ifdef CONFIG_INET
static int fc_rebuild_header(struct sk_buff *skb)
{
...
}
#else
static int fc_rebuild_header(struct sk_buff *skb)
{
	return 0;
}
#endif

Marcin
