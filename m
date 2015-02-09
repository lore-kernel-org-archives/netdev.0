From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 15/15] i40e/i40evf: Add call to u64_stats_init to init
Date: Mon, 09 Feb 2015 15:09:15 +0300
Message-ID: <54D8A36B.8040401@cogentembedded.com>
References: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com> <1423478641-3138-16-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:33563 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759439AbbBIMJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 07:09:19 -0500
Received: by labhz20 with SMTP id hz20so12826729lab.0
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 04:09:17 -0800 (PST)
In-Reply-To: <1423478641-3138-16-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/9/2015 1:44 PM, Jeff Kirsher wrote:

> From: Carolyn Wyborny <carolyn.wyborny@intel.com>

> This patch adds a call to u64_stats_init to Rx setup.
> This done in order to avoid lockdep errors with seqcount on newer kernels.

> Change-ID: Ia8ba8f0bcbd1c0e926f97d70aeee4ce4fd055e93
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 2 ++
>   drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 2 ++
>   2 files changed, 4 insertions(+)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> index 5aa6ef1..f4d6d90 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> @@ -1098,6 +1098,8 @@ int i40e_setup_rx_descriptors(struct i40e_ring *rx_ring)
>   	if (!rx_ring->rx_bi)
>   		goto err;
>
> +		u64_stats_init(rx_ring->syncp);

    This is over-indented.

> +
>   	/* Round up to nearest 4K */
>   	rx_ring->size = ring_is_16byte_desc_enabled(rx_ring)
>   		? rx_ring->count * sizeof(union i40e_16byte_rx_desc)
> diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> index 4bf15da..459499a 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> @@ -596,6 +596,8 @@ int i40evf_setup_rx_descriptors(struct i40e_ring *rx_ring)
>   	if (!rx_ring->rx_bi)
>   		goto err;
>
> +		u64_stats_init(rx_ring->syncp);

    Likewise.

> +
>   	/* Round up to nearest 4K */
>   	rx_ring->size = ring_is_16byte_desc_enabled(rx_ring)
>   		? rx_ring->count * sizeof(union i40e_16byte_rx_desc)

WBR, Sergei
