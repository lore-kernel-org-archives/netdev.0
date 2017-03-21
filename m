From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net 7/8] net/mlx5e: Count GSO packets correctly
Date: Tue, 21 Mar 2017 07:40:43 -0700
Message-ID: <f6cd891b-248f-86a7-f28c-2cd7a03929db@fb.com>
References: <20170321135919.25018-1-saeedm@mellanox.com>
 <20170321135919.25018-8-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
        Gal Pressman <galp@mellanox.com>, <kernel-team@fb.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50217 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757017AbdCUPC6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 11:02:58 -0400
In-Reply-To: <20170321135919.25018-8-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/21/17 6:59 AM, Saeed Mahameed wrote:
> From: Gal Pressman <galp@mellanox.com>
>
> TX packets statistics ('tx_packets' counter) used to count GSO packets
> as one, even though it contains multiple segments.
> This patch will increment the counter by the number of segments, and
> align the driver with the behavior of other drivers in the stack.
>
> Note that no information is lost in this patch due to 'tx_tso_packets'
> counter existence.
>
> Before, ethtool showed:
> $ ethtool -S ens6 | egrep "tx_packets|tx_tso_packets"
>      tx_packets: 61340
>      tx_tso_packets: 60954
>      tx_packets_phy: 2451115
>
> Now, we will see the more logical statistics:
> $ ethtool -S ens6 | egrep "tx_packets|tx_tso_packets"
>      tx_packets: 2451115
>      tx_tso_packets: 60954
>      tx_packets_phy: 2451115
>
> Fixes: e586b3b0baee ("net/mlx5: Ethernet Datapath files")
> Signed-off-by: Gal Pressman <galp@mellanox.com>
> Cc: kernel-team@fb.com
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

thank you for fixing!
Acked-by: Alexei Starovoitov <ast@kernel.org>
