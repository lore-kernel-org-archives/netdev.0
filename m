From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 00/12] Mellanox mlx5e XDP performance optimization
Date: Sun, 26 Mar 2017 11:16:38 +0200
Message-ID: <CALzJLG80OErFDz=6x3q4p3-tCNXV5RZeAK6E4dvYeCYpKQHCgQ@mail.gmail.com>
References: <20170324215214.25711-1-saeedm@mellanox.com> <CALx6S35AMWNeGDOx7d+M5Dqd-B60HGzwhmbLtcoPS2PfpA2m9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:35717 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751227AbdCZJRA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Mar 2017 05:17:00 -0400
Received: by mail-qk0-f180.google.com with SMTP id v127so19022240qkb.2
        for <netdev@vger.kernel.org>; Sun, 26 Mar 2017 02:16:59 -0700 (PDT)
In-Reply-To: <CALx6S35AMWNeGDOx7d+M5Dqd-B60HGzwhmbLtcoPS2PfpA2m9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 25, 2017 at 6:54 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Mar 24, 2017 at 2:52 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
>> Hi Dave,
>>
>> This series provides some preformancee optimizations for mlx5e
>> driver, especially for XDP TX flows.
>>
>> 1st patch is a simple change of rmb to dma_rmb in CQE fetch routine
>> which shows a huge gain for both RX and TX packet rates.
>>
>> 2nd patch removes write combining logic from the driver TX handler
>> and simplifies the TX logic while improving TX CPU utilization.
>>
>> All other patches combined provide some refactoring to the driver TX
>> flows to allow some significant XDP TX improvements.
>>
>> More details and performance numbers per patch can be found in each patch
>> commit message compared to the preceding patch.
>>
>> Overall performance improvemnets
>>   System: Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz
>>
>> Test case                   Baseline      Now      improvement
>> ---------------------------------------------------------------
>> TX packets (24 threads)     45Mpps        54Mpps      20%
>> TC stack Drop (1 core)      3.45Mpps      3.6Mpps     5%
>> XDP Drop      (1 core)      14Mpps        16.9Mpps    20%
>> XDP TX        (1 core)      10.4Mpps      13.7Mpps    31%
>>
> Awesome, and good timing. I'll be presenting XDP at IETF next and
> would like to include these numbers in the presentation if you don't
> mind...
>

Not at all, please go ahead.

But as you see, the system i tested on is not that powerful. We can
get even better results with a modern system.
If you want i can provide you those numbers by mid-week.
