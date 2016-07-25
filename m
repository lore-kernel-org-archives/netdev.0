From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/3] bnxt_en: Log a message, if enabling NTUPLE
 filtering fails.
Date: Mon, 25 Jul 2016 07:00:44 -0700
Message-ID: <1469455244.1900.178.camel@perches.com>
References: <1469416917-29659-1-git-send-email-michael.chan@broadcom.com>
	 <1469416917-29659-3-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0228.hostedemail.com ([216.40.44.228]:35543 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751105AbcGYOAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 10:00:50 -0400
In-Reply-To: <1469416917-29659-3-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-07-24 at 23:21 -0400, Michael Chan wrote:
> If there are not enough resources to enable ntuple filtering,
> log a warning message.
[]
> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/=
ethernet/broadcom/bnxt/bnxt.c
[]
> @@ -5790,8 +5790,14 @@ static bool bnxt_rfs_capable(struct bnxt *bp)
> =A0		return false;
> =A0
> =A0	vnics =3D 1 + bp->rx_nr_rings;
> -	if (vnics > pf->max_rsscos_ctxs || vnics > pf->max_vnics)
> +	if (vnics > pf->max_rsscos_ctxs || vnics > pf->max_vnics) {
> +		netdev_warn(bp->dev,
> +			=A0=A0=A0=A0"Not enough resources to support NTUPLE filters");
> +		netdev_warn(bp->dev,
> +			=A0=A0=A0=A0"Enough NTUPLE resources for up to %d rx rings",

Missing newline terminations and may be better as a single message
