From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 09/13] igb: Pull adapter out of main path in igb_xmit_frame_ring
Date: Thu, 04 Apr 2013 18:15:25 +0400
Message-ID: <515D8AFD.1000709@cogentembedded.com>
References: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com> <1365075480-20183-10-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:60929 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760960Ab3DDOQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 10:16:25 -0400
Received: by mail-la0-f42.google.com with SMTP id fe20so2548323lab.15
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 07:16:24 -0700 (PDT)
In-Reply-To: <1365075480-20183-10-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04-04-2013 15:37, Jeff Kirsher wrote:

> From: Alexander Duyck <alexander.h.duyck@intel.com>

> We only need the adapter pointer in the case of ptp.  As such we can pull the
> adapter out of the main path and place it inside the if statement to avoid
> the temptation of accessing the adapter pointer in the fast path.

> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

   Two minor nits.

> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index 29facb5..6043245 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
[...]
> @@ -4628,15 +4627,17 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
>
>   	skb_tx_timestamp(skb);
>
> -	if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
> -		     !(adapter->ptp_tx_skb))) {
> -		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
> -		tx_flags |= IGB_TX_FLAGS_TSTAMP;
> +	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
> +		struct igb_adapter *adapter = netdev_priv(tx_ring->netdev);

    An empty line wouldn't hurt here.

> +		if (!(adapter->ptp_tx_skb)) {

    Parens not needed here.

WBR, Sergei
