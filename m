From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH v2 net-next] liquidio: improve UDP TX performance
Date: Tue, 21 Feb 2017 13:18:27 -0800
Message-ID: <e5c4c230-ee1d-4783-154a-c6110d38724b@hpe.com>
References: <20170221210907.GA8045@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hpe.com ([15.233.16.89]:49852 "EHLO
        g2t1383g.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752218AbdBUVSb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 16:18:31 -0500
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com [15.241.48.72])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g2t1383g.austin.hpe.com (Postfix) with ESMTPS id C754629D
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 21:18:29 +0000 (UTC)
In-Reply-To: <20170221210907.GA8045@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/21/2017 01:09 PM, Felix Manlunas wrote:
> From: VSR Burru <veerasenareddy.burru@cavium.com>
>
> Improve UDP TX performance by:
> * reducing the ring size from 2K to 512
> * replacing the numerous streaming DMA allocations for info buffers and
>   gather lists with one large consistent DMA allocation per ring
>
> Netperf benchmark numbers before and after patch:
>
> PF UDP TX
> +--------+--------+------------+------------+---------+
> |        |        |  Before    |  After     |         |
> | Number |        |  Patch     |  Patch     |         |
> |  of    | Packet | Throughput | Throughput | Percent |
> | Flows  |  Size  |  (Gbps)    |  (Gbps)    | Change  |
> +--------+--------+------------+------------+---------+
> |        |   360  |   0.52     |   0.93     |  +78.9  |
> |   1    |  1024  |   1.62     |   2.84     |  +75.3  |
> |        |  1518  |   2.44     |   4.21     |  +72.5  |
> +--------+--------+------------+------------+---------+
> |        |   360  |   0.45     |   1.59     | +253.3  |
> |   4    |  1024  |   1.34     |   5.48     | +308.9  |
> |        |  1518  |   2.27     |   8.31     | +266.1  |
> +--------+--------+------------+------------+---------+
> |        |   360  |   0.40     |   1.61     | +302.5  |
> |   8    |  1024  |   1.64     |   4.24     | +158.5  |
> |        |  1518  |   2.87     |   6.52     | +127.2  |
> +--------+--------+------------+------------+---------+
>
>
> VF UDP TX
> +--------+--------+------------+------------+---------+
> |        |        |  Before    |  After     |         |
> | Number |        |  Patch     |  Patch     |         |
> |  of    | Packet | Throughput | Throughput | Percent |
> | Flows  |  Size  |  (Gbps)    |  (Gbps)    | Change  |
> +--------+--------+------------+------------+---------+
> |        |   360  |   1.28     |   1.49     |  +16.4  |
> |   1    |  1024  |   4.44     |   4.39     |   -1.1  |
> |        |  1518  |   6.08     |   6.51     |   +7.1  |
> +--------+--------+------------+------------+---------+
> |        |   360  |   2.35     |   2.35     |    0.0  |
> |   4    |  1024  |   6.41     |   8.07     |  +25.9  |
> |        |  1518  |   9.56     |   9.54     |   -0.2  |
> +--------+--------+------------+------------+---------+
> |        |   360  |   3.41     |   3.65     |   +7.0  |
> |   8    |  1024  |   9.35     |   9.34     |   -0.1  |
> |        |  1518  |   9.56     |   9.57     |   +0.1  |
> +--------+--------+------------+------------+---------+

Some good looking numbers there.  As one approaches the wire limit for 
bitrate, the likes of a netperf service demand can be used to 
demonstrate the performance change - though there isn't an easy way to 
do that for parallel flows.

happy benchmarking,

rick jones
