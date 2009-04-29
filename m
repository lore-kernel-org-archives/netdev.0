From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 3/6] net/ucc_geth: update riscTx and riscRx in ucc_geth
Date: Wed, 29 Apr 2009 15:23:21 -0500
Message-ID: <F640C411-797C-4A4D-BD1B-9A20114C57C3@kernel.crashing.org>
References: <1241028878175-git-send-email-Haiying.Wang@freescale.com> <12410288792524-git-send-email-Haiying.Wang@freescale.com> <12410288811793-git-send-email-Haiying.Wang@freescale.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Linuxppc-dev Development <linuxppc-dev@ozlabs.org>,
	Haiying Wang <Haiying.Wang@freescale.com>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52677 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753887AbZD2UZc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2009 16:25:32 -0400
In-Reply-To: <12410288811793-git-send-email-Haiying.Wang@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 29, 2009, at 1:14 PM, Haiying Wang wrote:

> Change the definition of riscTx and riscRx to unsigned integer  
> instead of enum,
> and change their values to support 4 risc allocation if the qe has 4  
> RISC
> engines.
>
> Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
> ---

Dave, if you can ack this it is probably easier if this goes via the  
powerpc tree as it had some dependancies.

- k

>
> drivers/net/ucc_geth.c |   14 +++++++++++---
> drivers/net/ucc_geth.h |    4 ++--
> 2 files changed, 13 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index d3f39e8..3e003fe 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -270,7 +270,7 @@ static int fill_init_enet_entries(struct  
> ucc_geth_private *ugeth,
> 				  u8 num_entries,
> 				  u32 thread_size,
> 				  u32 thread_alignment,
> -				  enum qe_risc_allocation risc,
> +				  unsigned int risc,
> 				  int skip_page_for_first_entry)
> {
> 	u32 init_enet_offset;
> @@ -307,7 +307,7 @@ static int fill_init_enet_entries(struct  
> ucc_geth_private *ugeth,
> static int return_init_enet_entries(struct ucc_geth_private *ugeth,
> 				    u32 *p_start,
> 				    u8 num_entries,
> -				    enum qe_risc_allocation risc,
> +				    unsigned int risc,
> 				    int skip_page_for_first_entry)
> {
> 	u32 init_enet_offset;
> @@ -342,7 +342,7 @@ static int dump_init_enet_entries(struct  
> ucc_geth_private *ugeth,
> 				  u32 __iomem *p_start,
> 				  u8 num_entries,
> 				  u32 thread_size,
> -				  enum qe_risc_allocation risc,
> +				  unsigned int risc,
> 				  int skip_page_for_first_entry)
> {
> 	u32 init_enet_offset;
> @@ -2134,6 +2134,14 @@ static int ucc_struct_init(struct  
> ucc_geth_private *ugeth)
> 		return -ENOMEM;
> 	}
>
> +	/* read the number of risc engines, update the riscTx and riscRx
> +	 * if there are 4 riscs in QE
> +	 */
> +	if (qe_get_num_of_risc() == 4) {
> +		ug_info->riscTx = QE_RISC_ALLOCATION_FOUR_RISCS;
> +		ug_info->riscRx = QE_RISC_ALLOCATION_FOUR_RISCS;
> +	}
> +
> 	ugeth->ug_regs = ioremap(uf_info->regs, sizeof(*ugeth->ug_regs));
> 	if (!ugeth->ug_regs) {
> 		if (netif_msg_probe(ugeth))
> diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
> index 2f8ee7c..46bb1d2 100644
> --- a/drivers/net/ucc_geth.h
> +++ b/drivers/net/ucc_geth.h
> @@ -1120,8 +1120,8 @@ struct ucc_geth_info {
> 	enum ucc_geth_maccfg2_pad_and_crc_mode padAndCrc;
> 	enum ucc_geth_num_of_threads numThreadsTx;
> 	enum ucc_geth_num_of_threads numThreadsRx;
> -	enum qe_risc_allocation riscTx;
> -	enum qe_risc_allocation riscRx;
> +	unsigned int riscTx;
> +	unsigned int riscRx;
> };
>
> /* structure representing UCC GETH */
> -- 
> 1.6.0.2

