From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/8] bnxt_en: Use common function to get ethtool
 supported flags.
Date: Sun, 6 Mar 2016 16:36:00 +0300
Message-ID: <56DC3240.5040409@cogentembedded.com>
References: <1457247684-2403-1-git-send-email-michael.chan@broadcom.com>
 <1457247684-2403-4-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:36720 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394AbcCFNgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 08:36:04 -0500
Received: by mail-lb0-f175.google.com with SMTP id x1so104860734lbj.3
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 05:36:02 -0800 (PST)
In-Reply-To: <1457247684-2403-4-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/6/2016 10:01 AM, Michael Chan wrote:

> The supported bits and advertising bits in ethtool have the same
> definitions.  The same is true for the firmware bits.  So use the
> common function to handle the conversion for both supported and
> advertising bits.
>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>   drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 29 +++++++----------------
>   1 file changed, 9 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
> index 591c290..e2fe967 100644
> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
[...]
> @@ -564,6 +545,15 @@ static u32 bnxt_fw_to_ethtool_lp_adv(struct bnxt_link_info *link_info)
>   	return _bnxt_fw_to_ethtool_adv_spds(fw_speeds, fw_pause);
>   }
>
> +static u32 bnxt_fw_to_ethtool_support_spds(struct bnxt_link_info *link_info)
> +{
> +	u16 fw_speeds = link_info->support_speeds;
> +	u32 supported;
> +
> +	supported = _bnxt_fw_to_ethtool_adv_spds(fw_speeds, 0);
> +	return (supported | SUPPORTED_Pause | SUPPORTED_Asym_Pause);

    Parens not needed here.

[...]

MBR, Sergei
