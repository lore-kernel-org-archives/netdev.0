From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH v5 net-next 4/7] net: mvneta: Convert to be 64 bits compatible
Date: Thu, 1 Dec 2016 13:33:52 +0100
Message-ID: <CAPv3WKftV+=CmpG6oN_86UytV+VVa3ZdkEmOcxGqmGZOqUwxHg@mail.gmail.com>
References: <cover.0270f6d2413a709521fe2c8c17fbebea6f2e78d1.1480542157.git-series.gregory.clement@free-electrons.com>
 <6b4d20a85b05e93d254e265eb07569dd1285d303.1480542157.git-series.gregory.clement@free-electrons.com>
 <20161201192604.07ed9516@xhacker> <CAPv3WKeJBL7_V_7QPVNDAd9H4bgeLcSF8enuD96sgEmecuRkRA@mail.gmail.com>
 <20161201200205.46dec339@xhacker> <20161201201648.6a50b442@xhacker>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cooper <jason@lakedaemon.net>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Dmitri Epshtein <dima@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Yelena Krivosheev <yelena@marvell.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        "David S. Miller" <davem@davemloft.net>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:36768 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933668AbcLAMdx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 07:33:53 -0500
Received: by mail-io0-f178.google.com with SMTP id m5so281860299ioe.3
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 04:33:53 -0800 (PST)
In-Reply-To: <20161201201648.6a50b442@xhacker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jisheng,

2016-12-01 13:16 GMT+01:00 Jisheng Zhang <jszhang@marvell.com>:
> On Thu, 1 Dec 2016 20:02:05 +0800 Jisheng Zhang wrote:
>
>> Hi Marcin,
>>
>> On Thu, 1 Dec 2016 12:48:39 +0100 Marcin Wojtas wrote:
>>
>> > Hi Jisheng,
>> >
>> > Which baseline do you use?
>> >
>> > It took me really lot of time to catch why RX broke after rebase from
>> > LKv4.1 to LKv4.4. Between those two, in commit:
>> > 97303480753e ("arm64: Increase the max granular size")
>> > L1_CACHE_BYTES for all ARMv8 platforms was increased to 128B and so
>> > did NET_SKB_PAD.
>> >
>> > And 128 is more than the maximum that can fit into packet offset
>> > [11:8]@0x1400. In such case this correction is needed. Did it answer
>> > your doubts?
>>
>> That's key! Thanks a lot. In my repo, we don't have commit 97303480753e
>> ("arm64: Increase the max granular size")
>>
>> I think it would be great if this information can be added into the commit
>> msg.
>>
>> IIRC, arm64 maintainers considered to let L1_CACHE_BYTES the _minimum_ of
>> cache line sizes of arm64. If that's implemented and merged, then we can
>
> I just searched and found the email.
>
> "We may have to revisit this logic and consider L1_CACHE_BYTES the
> _minimum_ of cache line sizes in arm64 systems supported by the kernel.
> Do you have any benchmarks on Cavium boards that would show significant
> degradation with 64-byte L1_CACHE_BYTES vs 128?"
>
> https://patchwork.kernel.org/patch/8634481/
>
>

Thank you for the information. I debugged it before the discussion. In
future we would be able to revert it, however afair packet offset may
be needed by A3700 Buffer Management.

Best regards,
Marcin
