From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] ixgbe: add the external ixgbe fiber transceiver
 status
Date: Thu, 9 Feb 2017 13:49:30 +0300
Message-ID: <27479fa3-47e7-5f01-1410-876a21e01523@cogentembedded.com>
References: <1486609408-6770-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Zhu Yanjun <yanjun.zhu@oracle.com>, jeffrey.t.kirsher@intel.com,
        broonie@kernel.org, davem@davemloft.net,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:36693 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752021AbdBIK5M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 05:57:12 -0500
Received: by mail-lf0-f43.google.com with SMTP id z134so99051105lff.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 02:56:01 -0800 (PST)
In-Reply-To: <1486609408-6770-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 2/9/2017 6:03 AM, Zhu Yanjun wrote:

> When the ixgbe fiber transceiver is external, it is necessary to get
> the present/absent status of this external ixgbe fiber transceiver.
>
> The steps to get the present/absent status:
> The enp1s0f0 is an external ixgbe fiber NIC.
>
> ethtool enp1s0f0
>
> ...
>         Port: FIBRE
>         PHYAD: 0
>         Transceiver: external(present) <---The transceiver is present.
>         Auto-negotiation: on
>         Supports Wake-on: d
> ...
>
> Or
> ...
>         Port: FIBRE
>         PHYAD: 0
>         Transceiver: external(absent) <---The transceiver is absent
>         Auto-negotiation: on
>         Supports Wake-on: d
> ...
>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 15 +++++++++++++++
>  include/uapi/linux/ethtool.h                     |  4 ++++
>  2 files changed, 19 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> index fd192bf..b3f86f4 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> @@ -313,6 +313,21 @@ static int ixgbe_get_settings(struct net_device *netdev,
>  		break;
>  	}
>
> +	/* When the tranceiver is external, the following is meaningful.
> +	 * ecmd->reserved[0] has 3 values:
> +	 * 0x0: tranceiver absent
> +	 * 0x4: tranceiver present
> +	 * others: not support
> +	 */
> +	if (ecmd->port == PORT_FIBRE) {
> +		u32 status = IXGBE_READ_REG(hw, IXGBE_ESDP) & IXGBE_ESDP_SDP2;
> +
> +		if (status == 0x4)
> +			ecmd->transceiver = XCVR_EXTERNAL_PRESENT;
> +		if (status == 0x0)

    *else* *if*. Although *switch* would match better instead...

> +			ecmd->transceiver = XCVR_EXTERNAL_ABSENT;
> +	}
> +
>  	/* Indicate pause support */
>  	ecmd->supported |= SUPPORTED_Pause;
>
[...]

MBR, Sergei
