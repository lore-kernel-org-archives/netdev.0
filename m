From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] cxgb4: Fix endian bug introduced in 76bcb31efc0685574fb123f7aaa92f8a50c14fd9
Date: Tue, 24 Jun 2014 17:55:54 +0400
Message-ID: <53A9836A.8000900@cogentembedded.com>
References: <1403569649-22649-1-git-send-email-anish@chelsio.com> <1403569649-22649-2-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, leedom@chelsio.com, hariprasad@chelsio.com
To: Anish Bhatt <anish@chelsio.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:47982 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521AbaFXNzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 09:55:52 -0400
Received: by mail-lb0-f179.google.com with SMTP id z11so476150lbi.24
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 06:55:51 -0700 (PDT)
In-Reply-To: <1403569649-22649-2-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/24/2014 04:27 AM, Anish Bhatt wrote:

    Please move the "introduced by <SHA1>" part of the subject into the 
changelog and add to <SHA1> the summary line of that commit in enclosed in 
parens. You can also add:

Fixes: <12-digit SHA1> ("<commit summary>")

before your signoff.

> Signed-off-by: Anish Bhatt <anish@chelsio.com>
> ---
>   drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
> index 39b4a85..a8b1073 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
> @@ -488,12 +488,12 @@ static void cxgb4_setpfccfg(struct net_device *dev, int priority, u8 pfccfg)
>   		pcmd.op_to_portid |= cpu_to_be32(FW_PORT_CMD_APPLY);
>
>   	pcmd.u.dcb.pfc.type = FW_PORT_DCB_TYPE_PFC;
> -	pcmd.u.dcb.pfc.pfcen = cpu_to_be16(pi->dcb.pfcen);
> +	pcmd.u.dcb.pfc.pfcen = pi->dcb.pfcen;
>
>   	if (pfccfg)
> -		pcmd.u.dcb.pfc.pfcen |= cpu_to_be16(1 << priority);
> +		pcmd.u.dcb.pfc.pfcen |= (1 << priority);
>   	else
> -		pcmd.u.dcb.pfc.pfcen &= cpu_to_be16(~(1 << priority));
> +		pcmd.u.dcb.pfc.pfcen &= (~(1 << priority));

    Outer () not needed here and above.

WBR, Sergei
