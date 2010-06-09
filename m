From: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Subject: RE: [patch] caif: fix a couple range checks
Date: Wed, 9 Jun 2010 11:11:38 +0200
Message-ID: <81C3A93C17462B4BBD7E272753C10579169C4D9E64@EXDCVYMBSTM005.EQ1STM.local>
References: <20100607145158.GO5483@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:32892 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757183Ab0FIJi0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 05:38:26 -0400
In-Reply-To: <20100607145158.GO5483@bicker>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Dan Carpenter [mailto:error27@gmail.com]
> 
> The extra ! character means that these conditions are always false.


Looks good, thanks. This is embarrassing, I should caught this ages ago.
Acked-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/net/caif/cfveil.c b/net/caif/cfveil.c
> index 0fd827f..e04f7d9 100644
> --- a/net/caif/cfveil.c
> +++ b/net/caif/cfveil.c
> @@ -84,7 +84,7 @@ static int cfvei_transmit(struct cflayer *layr,
> struct cfpkt *pkt)
>  		return ret;
>  	caif_assert(layr->dn != NULL);
>  	caif_assert(layr->dn->transmit != NULL);
> -	if (!cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
> +	if (cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
>  		pr_warning("CAIF: %s(): Packet too large - size=%d\n",
>  			   __func__, cfpkt_getlen(pkt));
>  		return -EOVERFLOW;
> diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
> index cd2830f..fd27b17 100644
> --- a/net/caif/cfrfml.c
> +++ b/net/caif/cfrfml.c
> @@ -83,7 +83,7 @@ static int cfrfml_transmit(struct cflayer *layr,
> struct cfpkt *pkt)
>  	if (!cfsrvl_ready(service, &ret))
>  		return ret;
> 
> -	if (!cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
> +	if (cfpkt_getlen(pkt) > CAIF_MAX_PAYLOAD_SIZE) {
>  		pr_err("CAIF: %s():Packet too large - size=%d\n",
>  			__func__, cfpkt_getlen(pkt));
>  		return -EOVERFLOW;
