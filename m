From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next 1/4] net: Add SRIOV VGT+ support
Date: Mon, 28 Aug 2017 17:52:17 +0200
Message-ID: <20170828155217.GA8399@bistromath.localdomain>
References: <20170827110618.20599-1-saeedm@mellanox.com>
 <20170827110618.20599-2-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40380 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751283AbdH1PwV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 11:52:21 -0400
Content-Disposition: inline
In-Reply-To: <20170827110618.20599-2-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-08-27, 14:06:15 +0300, Saeed Mahameed wrote:
[...]
> +#define VF_VLAN_BITMAP	DIV_ROUND_UP(VF_VLAN_N_VID, sizeof(__u64) * BITS_PER_BYTE)
> +struct ifla_vf_vlan_trunk {
> +	__u32 vf;
> +	__u64 allowed_vlans_8021q_bm[VF_VLAN_BITMAP];
> +	__u64 allowed_vlans_8021ad_bm[VF_VLAN_BITMAP];
> +};

This is huge (1032B). And you put one of these in the netlink message
for each VF.  This means that with 51 VF (at least in my environment,
where each VF takes 1296B), you're going to overflow the u16 size of a
single attribute (IFLA_VFINFO_LIST), and you cannot dump the device
anymore. I'm afraid this is going to break existing setups.

-- 
Sabrina
