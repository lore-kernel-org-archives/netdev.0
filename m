From: David Miller <davem@davemloft.net>
Subject: Re: tools: selftests: psock_tpacket: skip un-supported tpacket_v3
 test
Date: Sat, 23 Sep 2017 09:58:19 -0700 (PDT)
Message-ID: <20170923.095819.1589662822054224276.davem@davemloft.net>
References: <20170922101717.11933-1-orson.zhai@linaro.org>
        <20170922.182017.17747017677768533.davem@davemloft.net>
        <CAGNsrLBe2uhX_EhUgK+nKrRYSF54tktDNg5+ejQc6ia0T7F=ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: orson.zhai@linaro.org, shuah@kernel.org,
        milosz.wasilewski@linaro.org, sumit.semwal@linaro.org,
        netdev@vger.kernel.org, linux-kselftest@vger.kernel.org
To: fathi.boudra@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750778AbdIWQ6U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 12:58:20 -0400
In-Reply-To: <CAGNsrLBe2uhX_EhUgK+nKrRYSF54tktDNg5+ejQc6ia0T7F=ew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fathi Boudra <fathi.boudra@linaro.org>
Date: Sat, 23 Sep 2017 14:27:15 +0300

> On 23 September 2017 at 04:20, David Miller <davem@davemloft.net> wrote:
>> From: Orson Zhai <orson.zhai@linaro.org>
>> Date: Fri, 22 Sep 2017 18:17:17 +0800
>>
>>> The TPACKET_V3 test of PACKET_TX_RING will fail with kernel version
>>> lower than v4.11. Supported code of tx ring was add with commit id
>>> <7f953ab2ba46: af_packet: TX_RING support for TPACKET_V3> at Jan. 3
>>> of 2017.
>>>
>>> So skip this item test instead of reporting failing for old kernels.
>>>
>>> Signed-off-by: Orson Zhai <orson.zhai@linaro.org>
>>
>> The whole point is to make sure the kernel in which the selftest
>> code is present functions properly.
>>
>> There are many tests in selftests that only work on recent kernels.
> 
> For the background, a similar discussion happened on this thread:
> https://lkml.org/lkml/2017/6/22/802
> 
> There's cases where we'd like to run latest selftests on stable kernels.
> You're right, there are many tests in selftests that only work on
> recent kernels and we intend to fix it.
> Skipping gracefully a test because the feature is missing on the
> kernel under test is preferred to fail.

This approach is extremely ill advised.

It is hard enough to get developers to add new tests in the first
place.

Having the extra burdon of needing to make the test work on older
kernels is going to discourage test writing even more.

If you want to "backport" tests, handle them the same way -stable
backports are done.  With extreme care and making sure they get
backported to the kernel they actually would work on.
