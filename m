From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net 3/6] net/mlx5e: Do not reduce LRO WQE size when not
 using build_skb
Date: Thu, 23 Feb 2017 13:37:46 +0200
Message-ID: <CALzJLG9iEgw3ziiGnUWvhazPjge02AfKPXaRt1cq+yh28VacMQ@mail.gmail.com>
References: <20170222152016.31263-1-saeedm@mellanox.com> <20170222152016.31263-4-saeedm@mellanox.com>
 <CAADnVQKVj3MbjkstfcCsUy7DmqLGUtrq5=g=Bzd1u=bymcuVuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:35534 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbdBWLjF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 06:39:05 -0500
Received: by mail-qk0-f182.google.com with SMTP id u188so28737889qkc.2
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 03:38:07 -0800 (PST)
In-Reply-To: <CAADnVQKVj3MbjkstfcCsUy7DmqLGUtrq5=g=Bzd1u=bymcuVuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 22, 2017 at 9:45 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Wed, Feb 22, 2017 at 7:20 AM, Saeed Mahameed <saeedm@mellanox.com> wrote:
>> From: Tariq Toukan <tariqt@mellanox.com>
>>
>> When rq_type is Striding RQ, no room of SKB_RESERVE is needed
>> as SKB allocation is not done via build_skb.
>>
>> Fixes: e4b85508072b ("net/mlx5e: Slightly reduce hardware LRO size")
>> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
>> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>
> why this one is a bug fix?
> Sound like an optimization from commit log.

It is a regression since  ("net/mlx5e: Slightly reduce hardware LRO size").
And we see due to this a small drop in HW LRO performance.
We just fixed the LRO size to be the same as it was before the
offending patch for striding RQ case.
