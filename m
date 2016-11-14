From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH 3/5] net: thunderx: Fix configuration of L3/L4 length
 checking
Date: Mon, 14 Nov 2016 13:33:50 +0100
Message-ID: <20161114123350.GA2449@Red>
References: <1479120886-13425-1-git-send-email-sunil.kovvuri@gmail.com>
 <1479120886-13425-4-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Sunil Goutham <sgoutham@cavium.com>,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: sunil.kovvuri@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34725 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932258AbcKNMdz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 07:33:55 -0500
Content-Disposition: inline
In-Reply-To: <1479120886-13425-4-git-send-email-sunil.kovvuri@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2016 at 04:24:44PM +0530, sunil.kovvuri@gmail.com wrote:
> From: Sunil Goutham <sgoutham@cavium.com>
> 
> This patch fixes enabling of HW verification of L3/L4 length and
> TCP/UDP checksum which is currently being cleared. Also fixed VLAN
> stripping config which is being cleared when multiqset is enabled.
> 
> Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
> ---
>  drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
> index f0e0ca6..3050177 100644
> --- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
> +++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
> @@ -538,9 +538,12 @@ static void nicvf_rcv_queue_config(struct nicvf *nic, struct queue_set *qs,
>  	mbx.rq.cfg = (1ULL << 62) | (RQ_CQ_DROP << 8);
>  	nicvf_send_msg_to_pf(nic, &mbx);
>  
> -	nicvf_queue_reg_write(nic, NIC_QSET_RQ_GEN_CFG, 0, 0x00);
> -	if (!nic->sqs_mode)
> +	if (!nic->sqs_mode && (qidx == 0)) {
> +		/* Enable checking L3/L4 length and TCP/UDP checksums */
> +		nicvf_queue_reg_write(nic, NIC_QSET_RQ_GEN_CFG, 0,
> +				      ((1 << 24) | (1 << 23) | (1 << 21)));

Hello

You could use the BIT() macro here

Regards
