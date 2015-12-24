From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next PATCH 05/10] be2net: log digital signature errors while
 flashing FW image
Date: Thu, 24 Dec 2015 16:23:07 +0300
Message-ID: <567BF1BB.50201@cogentembedded.com>
References: <1450949192-4574-1-git-send-email-sathya.perla@avagotech.com>
 <1450949192-4574-6-git-send-email-sathya.perla@avagotech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Sathya Perla <sathya.perla@avagotech.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:36021 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbbLXNXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 08:23:10 -0500
Received: by mail-lb0-f176.google.com with SMTP id oh2so60423125lbb.3
        for <netdev@vger.kernel.org>; Thu, 24 Dec 2015 05:23:10 -0800 (PST)
In-Reply-To: <1450949192-4574-6-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/24/2015 12:26 PM, Sathya Perla wrote:

> From: Suresh Reddy <suresh.reddy@avagotech.com>
>
>  From FW version 11.0 onwards, the FW supports a new "secure mode" feature
> (based on a jumper setting on the adapter.) In this mode, the FW image when
> flashed is authenticated with a digital signature. This patch logs
> appropriate error messages and return a status to ethtool when errors
> relating to FW image authentication occur.
>
> Signed-off-by: Suresh Reddy <suresh.reddy@avagotech.com>
> Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
> ---
>   drivers/net/ethernet/emulex/benet/be_cmds.c | 11 +++++++++++
>   drivers/net/ethernet/emulex/benet/be_cmds.h |  4 +++-
>   2 files changed, 14 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
> index da3b398..6fb7873 100644
> --- a/drivers/net/ethernet/emulex/benet/be_cmds.c
> +++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
> @@ -2959,6 +2959,17 @@ flash:
>   		} else if (status) {
>   			dev_err(dev, "Flashing section type 0x%x failed\n",
>   				img_type);
> +			if (addl_status(status) ==
> +			    MCC_ADDL_STATUS_MISSING_SIGNATURE) {
> +				dev_err(dev,
> +					"Digital signature missing in FW\n");
> +				return -EINVAL;
> +			} else if (addl_status(status) ==
> +				   MCC_ADDL_STATUS_INVALID_SIGNATURE) {
> +				dev_err(dev,
> +					"Invalid digital signature in FW\n");
> +				return -EINVAL;
> +			}

    Asks to be a *switch* statement.

[...]

MBR, Sergei
