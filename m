From: "Ariel Elior" <ariele@broadcom.com>
Subject: RE: [PATCH -next] bnx2x: use list_move instead of
 list_del/list_add
Date: Mon, 11 Mar 2013 16:53:30 +0000
Message-ID: <6AE768456CEC4B4A9B2248CB6B87EB3E1BD109CC@SJEXCHMB05.corp.ad.broadcom.com>
References: <CAPgLHd8f_Vq40sB9SaD-3wsHp34ifQ7X+uoMUNDfjFHcy4wJkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Wei Yongjun" <weiyj.lk@gmail.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4176 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753404Ab3CKQ4X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 12:56:23 -0400
In-Reply-To: <CAPgLHd8f_Vq40sB9SaD-3wsHp34ifQ7X+uoMUNDfjFHcy4wJkQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, March 11, 2013 4:40 PM Wei Yongjun wrote:
> Using list_move() instead of list_del() + list_add().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> index 71fcef0..c32a066 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> @@ -556,8 +556,7 @@ static int bnx2x_vfop_config_list(struct bnx2x *bp,
>  		rc = bnx2x_config_vlan_mac(bp, vlan_mac);
>  		if (rc >= 0) {
>  			cnt += pos->add ? 1 : -1;
> -			list_del(&pos->link);
> -			list_add(&pos->link, &rollback_list);
> +			list_move(&pos->link, &rollback_list);
>  			rc = 0;
>  		} else if (rc == -EEXIST) {
>  			rc = 0;
> 
> --

Thanks

Acked-by: Ariel Elior <ariele@broadcom.com>
