From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net 3/4] net/mlx4_en: Fix wrong csum complete report when
 rxvlan offload is disabled
Date: Thu, 25 Jun 2015 09:36:11 +0300
Message-ID: <558BA15B.3030106@mellanox.com>
References: <1435159323-10028-1-git-send-email-ogerlitz@mellanox.com>
	 <1435159323-10028-4-git-send-email-ogerlitz@mellanox.com>
 <1435183281.4110.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Amir Vadai" <amirv@mellanox.com>, Ido Shamay <idos@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0075.outbound.protection.outlook.com ([157.55.234.75]:45536
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751023AbbFYGgG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2015 02:36:06 -0400
In-Reply-To: <1435183281.4110.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/25/2015 1:01 AM, Eric Dumazet wrote:
> On Wed, 2015-06-24 at 18:22 +0300, Or Gerlitz wrote:
>> From: Ido Shamay <idos@mellanox.com>
>>
>> +	if (be32_to_cpu(cqe->vlan_my_qpn) & MLX4_CQE_VLAN_PRESENT_MASK &&
>> +	    !(dev_features & NETIF_F_HW_VLAN_CTAG_RX)) {
>>   		hw_checksum = get_fixed_vlan_csum(hw_checksum, hdr);
>>   		hdr += sizeof(struct vlan_hdr);
> This is faster to use
>
> if (cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK) &&
>
>
>
sure, will fix that and re-spin the series

Or.
