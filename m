From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next 00/10] bnxt_en: Add XDP support.
Date: Wed, 1 Feb 2017 00:33:40 -0500
Message-ID: <CAHashqCH53_6-fM=3-K86y76uEw7DpQgqtO9DBAShQgnz2dQdw@mail.gmail.com>
References: <20170131153647.GA77071@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michael Chan <michael.chan@broadcom.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36824 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750991AbdBAFeC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 00:34:02 -0500
Received: by mail-qk0-f193.google.com with SMTP id i34so24386908qkh.3
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 21:34:01 -0800 (PST)
In-Reply-To: <20170131153647.GA77071@C02RW35GFVH8.dhcp.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 10:36 AM, Andy Gospodarek <andy@greyhouse.net> wrote:
> On Mon, Jan 30, 2017 at 08:47:47PM -0800, Alexei Starovoitov wrote:
>> On Mon, Jan 30, 2017 at 08:49:25PM -0500, Michael Chan wrote:
>> > The first 8 patches refactor the code (rx/tx code paths and ring logic)
>> > and add the basic infrastructure to support XDP.  The 9th patch adds
>> > basic ndo_xdp to support XDP_DROP and XDP_PASS only.  The 10th patch
>> > completes the series with XDP_TX.
>>
>> Looks great.
>> Could you please share performance numbers ?
>
> I'll post some later today.

I finally got my system moved around to what I'd hoped would be the
right spot in my lab, but the system used for generating the traffic
was only able to send 6Mpps with pktgen, so it was not a great test.

My receiving system with i7-6700 CPU @ 3.40GHz seemed to have no issue
handling this 6Mpps load -- mpstat showed only one core was ~25%
utilitzed with all of that servicing softirqs.  The rest of the cores
were 100% idle.

I'm going to search for other traffic generation tools/systems to make
sure I can get at least line-rate for the 10GbE cards I was using.

>
>>
>> Also please add something like:
>>   if (prog && prog->xdp_adjust_head) {
>>           netdev_warn(dev, "Does not support bpf_xdp_adjust_head()\n");
>>           return -EOPNOTSUPP;
>>   }
>> unless you plan to add adjut_head support until net-next closes.
>> Note, it's must have for load balancer functionality.
