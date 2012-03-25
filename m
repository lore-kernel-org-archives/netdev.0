From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH] e1000: Silence sparse warnings by correcting type
Date: Sun, 25 Mar 2012 02:45:13 -0700
Message-ID: <4F6EE929.9090100@gmail.com>
References: <1332233951-31129-1-git-send-email-Andrei.Emeltchenko.news@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrei Emeltchenko <Andrei.Emeltchenko.news@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7410 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754188Ab2CYJpO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Mar 2012 05:45:14 -0400
In-Reply-To: <1332233951-31129-1-git-send-email-Andrei.Emeltchenko.news@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2012 01:59 AM, Andrei Emeltchenko wrote:
> From: Andrei Emeltchenko<andrei.emeltchenko@intel.com>
>
> Silence sparse warnings shown below:
> ...
> drivers/net/ethernet/intel/e1000/e1000_main.c:3435:17: warning:
> 	cast to restricted __le64
> drivers/net/ethernet/intel/e1000/e1000_main.c:3435:17: warning:
> 	cast to restricted __le64
> ...
>
> Signed-off-by: Andrei Emeltchenko<andrei.emeltchenko@intel.com>
> ---
>   drivers/net/ethernet/intel/e1000/e1000_main.c |    4 ++--
>   1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index 6419a88..1bf73cf 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -3377,7 +3377,7 @@ static void e1000_dump(struct e1000_adapter *adapter)
>   	for (i = 0; tx_ring->desc&&  (i<  tx_ring->count); i++) {
>   		struct e1000_tx_desc *tx_desc = E1000_TX_DESC(*tx_ring, i);
>   		struct e1000_buffer *buffer_info =&tx_ring->buffer_info[i];
> -		struct my_u { u64 a; u64 b; };
> +		struct my_u { __le64 a; __le64 b; };
>   		struct my_u *u = (struct my_u *)tx_desc;
>   		const char *type;
>
> @@ -3421,7 +3421,7 @@ rx_ring_summary:
>   	for (i = 0; rx_ring->desc&&  (i<  rx_ring->count); i++) {
>   		struct e1000_rx_desc *rx_desc = E1000_RX_DESC(*rx_ring, i);
>   		struct e1000_buffer *buffer_info =&rx_ring->buffer_info[i];
> -		struct my_u { u64 a; u64 b; };
> +		struct my_u { __le64 a; __le64 b; };
>   		struct my_u *u = (struct my_u *)rx_desc;
>   		const char *type;
>
Helps if you CC the maintainers (i.e. me)

Thanks, I will add it to my queue of e1000 patches.
