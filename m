From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 4/8] be2net: SRIOV Queue distribution should
 factor in EQ-count of VFs
Date: Tue, 2 Feb 2016 17:30:48 +0300
Message-ID: <56B0BD98.50809@cogentembedded.com>
References: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
 <1454408435-11575-5-git-send-email-sriharsha.basavapatna@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:36084 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbcBBOav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 09:30:51 -0500
Received: by mail-lb0-f169.google.com with SMTP id dx2so95319581lbd.3
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 06:30:50 -0800 (PST)
In-Reply-To: <1454408435-11575-5-git-send-email-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/2/2016 1:20 PM, Sriharsha Basavapatna wrote:

> The SRIOV resource distribution logic for RX/TX queue counts is not optimal
> when a small number of VFs are enabled. It does not take into account the
> VF's EQ count while computing the queue counts. Because of this, the VF
> gets a large number of queues, though it doesn't have sufficient EQs,
> resulting in wasted queue resources. And the PF gets a smaller share of
> queues though it has more EQs. Fix this by capping the VF queue count at
> its EQ count.
>
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> ---
>   drivers/net/ethernet/emulex/benet/be.h      |  4 ++++
>   drivers/net/ethernet/emulex/benet/be_main.c | 15 ++++++---------
>   2 files changed, 10 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
> index cf83783..f33d73c 100644
> --- a/drivers/net/ethernet/emulex/benet/be.h
> +++ b/drivers/net/ethernet/emulex/benet/be.h
> @@ -89,6 +89,10 @@
>   #define BE3_MAX_TX_QS		16
>   #define BE3_MAX_EVT_QS		16
>   #define BE3_SRIOV_MAX_EVT_QS	8
> +#define	SH_VF_MAX_NIC_EQS	3	/* Skyhawk VFs can have a max of 4 EQs

    Other #define's seem to have a space after them, not tab...

> +					 * and at least 1 is granted to either
> +					 * SURF/DPDK
> +					 */
>
>   #define MAX_RSS_IFACES		15
>   #define MAX_RX_QS		32
[...]

MBR, Sergei
