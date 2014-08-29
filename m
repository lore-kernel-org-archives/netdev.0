From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 08/15] i40e: fix panic due to too-early Tx queue enable
Date: Fri, 29 Aug 2014 21:08:33 +0400
Message-ID: <5400B391.9020700@cogentembedded.com>
References: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com> <1409304620-23251-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:40748 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115AbaH2RIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 13:08:38 -0400
Received: by mail-la0-f46.google.com with SMTP id pv20so3079881lab.33
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 10:08:36 -0700 (PDT)
In-Reply-To: <1409304620-23251-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/29/2014 01:30 PM, Jeff Kirsher wrote:

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>

> This fixes the panic under traffic load when resetting.  This issue
> could also show up if/whenever there is a Tx-timeout.

> Change-ID: Ie393a1f17fd5d962e56fc3bfe784899ef25402f5
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Tested-by: Jim Young <jamesx.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 64b8683..d37dea1 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -5289,7 +5289,7 @@ static void i40e_fdir_reinit_subtask(struct i40e_pf *pf)
>    **/
>   static void i40e_vsi_link_event(struct i40e_vsi *vsi, bool link_up)
>   {
> -	if (!vsi)
> +	if (!vsi || (test_bit(__I40E_DOWN, &vsi->state)))

    Enclosing function call into parens is totally pointless.

WBR, Sergei
