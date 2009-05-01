From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 5/6 v2] net/ucc_geth: Assign six threads to Rx for UEC
Date: Fri, 1 May 2009 16:56:19 -0500
Message-ID: <F2CB7830-33F9-4F6C-A782-6B086166FC4D@kernel.crashing.org>
References: <1241206851-27749-1-git-send-email-Haiying.Wang@freescale.com> <1241206851-27749-2-git-send-email-Haiying.Wang@freescale.com> <1241206851-27749-3-git-send-email-Haiying.Wang@freescale.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Linuxppc-dev Development <linuxppc-dev@ozlabs.org>,
	Haiying Wang <Haiying.Wang@freescale.com>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54827 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753336AbZEAV6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2009 17:58:31 -0400
In-Reply-To: <1241206851-27749-3-git-send-email-Haiying.Wang@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 1, 2009, at 2:40 PM, Haiying Wang wrote:

> in the case the QE has 46 SNUMs for the threads to support four UCC  
> Ethernet at
> 1000Base-T simultaneously.
>
> Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
> ---
> v2 change: Add comments for the Rx threads change.
> drivers/net/ucc_geth.c |   10 +++++++++-
> 1 files changed, 9 insertions(+), 1 deletions(-)

Dave,

One more patch for you to Ack and let me handle via the powerpc tree  
because of dependencies.

- k

>
>
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index 44f8392..1cb2710 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -3702,7 +3702,15 @@ static int ucc_geth_probe(struct of_device*  
> ofdev, const struct of_device_id *ma
> 		ug_info->uf_info.utfet = UCC_GETH_UTFET_GIGA_INIT;
> 		ug_info->uf_info.utftt = UCC_GETH_UTFTT_GIGA_INIT;
> 		ug_info->numThreadsTx = UCC_GETH_NUM_OF_THREADS_4;
> -		ug_info->numThreadsRx = UCC_GETH_NUM_OF_THREADS_4;
> +
> +		/* If QE's snum number is 46 which means we need to support
> +		 * 4 UECs at 1000Base-T simultaneously, we need to allocate
> +		 * more Threads to Rx.
> +		 */
> +		if (qe_get_num_of_snums() == 46)
> +			ug_info->numThreadsRx = UCC_GETH_NUM_OF_THREADS_6;
> +		else
> +			ug_info->numThreadsRx = UCC_GETH_NUM_OF_THREADS_4;
> 	}
>
> 	if (netif_msg_probe(&debug))
> -- 
> 1.6.0.2

