From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 3/4] net/mlx4_en: Fix wrong csum complete report
 when rxvlan offload is disabled
Date: Thu, 25 Jun 2015 00:01:21 +0200
Message-ID: <1435183281.4110.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1435159323-10028-1-git-send-email-ogerlitz@mellanox.com>
	 <1435159323-10028-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>, Ido Shamay <idos@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:32920 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbbFXWBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 18:01:25 -0400
Received: by wiwl6 with SMTP id l6so1212902wiw.0
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2015 15:01:23 -0700 (PDT)
In-Reply-To: <1435159323-10028-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-24 at 18:22 +0300, Or Gerlitz wrote:
> From: Ido Shamay <idos@mellanox.com>
> 

> +	if (be32_to_cpu(cqe->vlan_my_qpn) & MLX4_CQE_VLAN_PRESENT_MASK &&
> +	    !(dev_features & NETIF_F_HW_VLAN_CTAG_RX)) {
>  		hw_checksum = get_fixed_vlan_csum(hw_checksum, hdr);
>  		hdr += sizeof(struct vlan_hdr);

This is faster to use 

if (cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK) &&
