From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net 5/7] igb: fix stats for i210 rx_fifo_errors
Date: Sun, 20 Apr 2014 01:58:23 +0400
Message-ID: <5352F17F.3080907@cogentembedded.com>
References: <1397872767-4001-1-git-send-email-jeffrey.t.kirsher@intel.com> <1397872767-4001-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net, Todd Fujinaka <todd.fujinaka@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:42554 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbaDSV6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2014 17:58:25 -0400
Received: by mail-la0-f46.google.com with SMTP id hr17so2262969lab.33
        for <netdev@vger.kernel.org>; Sat, 19 Apr 2014 14:58:24 -0700 (PDT)
In-Reply-To: <1397872767-4001-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/19/2014 05:59 AM, Jeff Kirsher wrote:

> From: Todd Fujinaka <todd.fujinaka@intel.com>

> RQDPC on i210/i211 is R/W not ReadClear. Clear after reading.

> Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/igb/igb_main.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index fb98d46..16430a8 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -5193,8 +5193,10 @@ void igb_update_stats(struct igb_adapter *adapter,
>
>   	rcu_read_lock();
>   	for (i = 0; i < adapter->num_rx_queues; i++) {
> -		u32 rqdpc = rd32(E1000_RQDPC(i));
>   		struct igb_ring *ring = adapter->rx_ring[i];
> +		u32 rqdpc = rd32(E1000_RQDPC(i));

    Empty line needed after declaration. It was present before this patch.

> +		if (hw->mac.type >= e1000_i210)
> +			wr32(E1000_RQDPC(i), 0);
>
>   		if (rqdpc) {
>   			ring->rx_stats.drops += rqdpc;

WBR, Sergei
