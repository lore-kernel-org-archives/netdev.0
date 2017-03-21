From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net 8/8] net/mlx5e: Count LRO packets correctly
Date: Tue, 21 Mar 2017 07:41:11 -0700
Message-ID: <363380b9-38c8-095d-bcb2-468c29d7fc2a@fb.com>
References: <20170321135919.25018-1-saeedm@mellanox.com>
 <20170321135919.25018-9-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
        Gal Pressman <galp@mellanox.com>, <kernel-team@fb.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36061 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1756639AbdCUPC4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 11:02:56 -0400
In-Reply-To: <20170321135919.25018-9-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/21/17 6:59 AM, Saeed Mahameed wrote:
> From: Gal Pressman <galp@mellanox.com>
>
> RX packets statistics ('rx_packets' counter) used to count LRO packets
> as one, even though it contains multiple segments.
> This patch will increment the counter by the number of segments, and
> align the driver with the behavior of other drivers in the stack.
>
> Note that no information is lost in this patch due to 'rx_lro_packets'
> counter existence.
>
> Before, ethtool showed:
> $ ethtool -S ens6 | egrep "rx_packets|rx_lro_packets"
>      rx_packets: 435277
>      rx_lro_packets: 35847
>      rx_packets_phy: 1935066
>
> Now, we will see the more logical statistics:
> $ ethtool -S ens6 | egrep "rx_packets|rx_lro_packets"
>      rx_packets: 1935066
>      rx_lro_packets: 35847
>      rx_packets_phy: 1935066
>
> Fixes: e586b3b0baee ("net/mlx5: Ethernet Datapath files")
> Signed-off-by: Gal Pressman <galp@mellanox.com>
> Cc: kernel-team@fb.com
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
