From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 00/12] Mellanox mlx5e XDP performance
 optimization
Date: Fri, 24 Mar 2017 16:26:25 -0700
Message-ID: <420dc52e-8b39-a083-941e-d87eb941771a@fb.com>
References: <20170324215214.25711-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:34539 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754764AbdCXX0k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 19:26:40 -0400
In-Reply-To: <20170324215214.25711-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/24/17 2:52 PM, Saeed Mahameed wrote:
> Hi Dave,
>
> This series provides some preformancee optimizations for mlx5e
> driver, especially for XDP TX flows.
>
> 1st patch is a simple change of rmb to dma_rmb in CQE fetch routine
> which shows a huge gain for both RX and TX packet rates.
>
> 2nd patch removes write combining logic from the driver TX handler
> and simplifies the TX logic while improving TX CPU utilization.
>
> All other patches combined provide some refactoring to the driver TX
> flows to allow some significant XDP TX improvements.
>
> More details and performance numbers per patch can be found in each patch
> commit message compared to the preceding patch.
>
> Overall performance improvemnets
>   System: Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz
>
> Test case                   Baseline      Now      improvement
> ---------------------------------------------------------------
> TX packets (24 threads)     45Mpps        54Mpps      20%
> TC stack Drop (1 core)      3.45Mpps      3.6Mpps     5%
> XDP Drop      (1 core)      14Mpps        16.9Mpps    20%
> XDP TX        (1 core)      10.4Mpps      13.7Mpps    31%

Excellent work!
All patches look great, so for the series:
Acked-by: Alexei Starovoitov <ast@kernel.org>

in patch 12 I noticed that inline_mode is being evaluated.
I think for xdp queues it's guaranteed to be fixed.
Can we optimize that path little bit more as well?
Thanks!
