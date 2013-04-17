From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 3/7] qlcnic: Enhanced channel configuration
 logs
Date: Wed, 17 Apr 2013 21:48:01 +0400
Message-ID: <516EE051.3030808@cogentembedded.com>
References: <1366218359-17701-1-git-send-email-shahed.shaikh@qlogic.com> <1366218359-17701-4-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Manish Chopra <manish.chopra@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:62946 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965673Ab3DQRsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 13:48:51 -0400
Received: by mail-lb0-f180.google.com with SMTP id t11so1893824lbi.11
        for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 10:48:49 -0700 (PDT)
In-Reply-To: <1366218359-17701-4-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/17/2013 09:05 PM, Shahed Shaikh wrote:

> From: Manish Chopra <manish.chopra@qlogic.com>
>
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
[...]
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> index edbc85f..f35c504 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -3240,20 +3240,41 @@ qlcnicvf_start_firmware(struct qlcnic_adapter *adapter)
>   	return err;
>   }
>   
> -int qlcnic_validate_max_rss(u8 max_hw, u8 val)
> +int qlcnic_validate_max_rss(struct qlcnic_adapter *adapter,
> +			    __u32 val)
>   {
[...]
> -	if ((val > max_allowed) || (val < 2) || !is_power_of_2(val)) {
> -		pr_info("rss_ring valid range [2 - %x] in powers of 2\n",
> -			max_allowed);
> +
> +	if ((val > max_allowed) || (val <  2) || !is_power_of_2(val)) {

    Too many spaces between < and 2. And () not needed around > and <.
This line overall looks like random unneeded change.

> +		if (val > num_online_cpus())
> +			netdev_err(netdev,
> +				   "RSS value should not be higher than[%u], the max number of CPUs in the system\n",
> +				   num_online_cpus());

    num_online_cpus() doesn't yield the max number of CPUs in the system,
it yields what it says, number of online CPUs.

WBR, Sergei
