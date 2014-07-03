From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 04/14] i40e: tolerate lost interrupts
Date: Thu, 03 Jul 2014 16:15:19 +0400
Message-ID: <53B54957.70408@cogentembedded.com>
References: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com> <1404355233-30123-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com
To: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:61219 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbaGCMPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 08:15:17 -0400
Received: by mail-lb0-f180.google.com with SMTP id w7so90787lbi.11
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2014 05:15:14 -0700 (PDT)
In-Reply-To: <1404355233-30123-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07/03/2014 06:40 AM, Jeff Kirsher wrote:

> From: Mitch Williams <mitch.a.williams@intel.com>

> If the AQ interrupt gets lost for some reason, VF communications will
> stall as the VFs have no way of reaching the PF, which is essentially
> deaf. The VFs end up waiting forever for a reply that will never come.

> To alleviate this condition, go ahead and check the ARQ every time we
> run the service task. Remove the check for a pending event, and get rid
> of a chatty error message that is now meaningless.

> Change-ID: I0fc9d18169cd45c98f60188aef872cd6cee9a027
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Tested-by: Jim Young <jamesx.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++------
>   1 file changed, 2 insertions(+), 6 deletions(-)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 440b671..88704c0 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
[...]
> @@ -5360,10 +5357,9 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
>   	do {
>   		event.msg_size = I40E_MAX_AQ_BUF_SIZE; /* reinit each time */
>   		ret = i40e_clean_arq_element(hw, &event, &pending);
> -		if (ret == I40E_ERR_ADMIN_QUEUE_NO_WORK) {
> -			dev_info(&pf->pdev->dev, "No ARQ event found\n");
> +		if (ret == I40E_ERR_ADMIN_QUEUE_NO_WORK)
>   			break;
> -		} else if (ret) {
> +		else if (ret) {

    Keep {} around both arms of the *if* statement please, according to the 
kernel coding style.

>   			dev_info(&pf->pdev->dev, "ARQ event error %d\n", ret);
>   			break;
>   		}
>

WBR, Sergei
