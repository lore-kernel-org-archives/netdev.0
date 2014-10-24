From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 8/9] i40e: Moving variable declaration out of the loops
Date: Fri, 24 Oct 2014 16:20:19 +0400
Message-ID: <544A4403.9090108@cogentembedded.com>
References: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com> <1414123806-20049-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Patrick Lu <patrick.lu@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:36772 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756501AbaJXMUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 08:20:23 -0400
Received: by mail-la0-f54.google.com with SMTP id gm9so2551630lab.13
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 05:20:21 -0700 (PDT)
In-Reply-To: <1414123806-20049-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/24/2014 8:10 AM, Jeff Kirsher wrote:

> From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

> Move the three variables out of the loop, so it only declares once.

    It's only declared once in either case. I think gcc allocates maximum 
local variable space at the start of the function, so declaring variables in 
the loop body comes with no extra price.

> Change-ID: I436913777c7da3c16dc0031b59e3ffa61de74718
> Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
> Signed-off-by: Patrick Lu <patrick.lu@intel.com>
> Tested-by: Jim Young <jamesx.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c | 7 +++----
>   1 file changed, 3 insertions(+), 4 deletions(-)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 9d36d10..b0c10e0 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -813,7 +813,10 @@ static void i40e_update_vsi_stats(struct i40e_vsi *vsi)
>   	struct i40e_eth_stats *oes;
>   	struct i40e_eth_stats *es;     /* device's eth stats */
>   	u32 tx_restart, tx_busy;
> +	struct i40e_ring *p;
>   	u32 rx_page, rx_buf;
> +	u64 bytes, packets;
> +	unsigned int start;
>   	u64 rx_p, rx_b;
>   	u64 tx_p, tx_b;
>   	u16 q;
> @@ -837,10 +840,6 @@ static void i40e_update_vsi_stats(struct i40e_vsi *vsi)
>   	rx_buf = 0;
>   	rcu_read_lock();
>   	for (q = 0; q < vsi->num_queue_pairs; q++) {
> -		struct i40e_ring *p;
> -		u64 bytes, packets;
> -		unsigned int start;
> -

WBR, Sergei
