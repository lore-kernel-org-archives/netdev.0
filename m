From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 5/5] qlcnic: reset firmware API lock during driver
 load
Date: Fri, 21 Feb 2014 18:36:29 +0400
Message-ID: <5307646D.4050801@cogentembedded.com>
References: <1392963788-18341-1-git-send-email-shahed.shaikh@qlogic.com> <1392963788-18341-6-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:34183 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754342AbaBUOg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 09:36:26 -0500
Received: by mail-la0-f51.google.com with SMTP id c6so2391435lan.10
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 06:36:25 -0800 (PST)
In-Reply-To: <1392963788-18341-6-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 21-02-2014 10:23, Shahed Shaikh wrote:

> From: Sony Chacko <sony.chacko@qlogic.com>

> Firmware is not resetting API lock at initialization,
> reset the lock at driver load time.

> Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
> ---
>   drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 13 +++++++++++++
>   1 file changed, 13 insertions(+)

> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> index 1222865..61f8893 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -2305,6 +2305,18 @@ void qlcnic_set_drv_version(struct qlcnic_adapter *adapter)
>   		qlcnic_fw_cmd_set_drv_version(adapter, fw_cmd);
>   }
>
> +static void qlcnic_reset_api_lock(struct qlcnic_adapter *adapter)
> +{
> +	/* Check lock availability*/
> +	if (qlcnic_api_lock(adapter)) {
> +		/* Lock not available, force release the lock */
> +		qlcnic_api_unlock(adapter);
> +	} else {
> +		/* Lock available, release it before proceeding */
> +		qlcnic_api_unlock(adapter);
> +	}

    Isn't it simpler to just do:

	qlcnic_api_lock(adapter);
	qlcnic_api_unlock(adapter);

> +}
> +
>   static int
>   qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>   {

WBR, Sergei
