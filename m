From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 11/12] mlxsw: spectrum_dpipe: Add support for
 IPv4 host table dump
Date: Tue, 29 Aug 2017 09:55:13 +0200
Message-ID: <20170829075513.GC1977@nanopsycho.orion>
References: <20170824064010.1646-1-jiri@resnulli.us>
 <20170824064010.1646-12-jiri@resnulli.us>
 <e5af97b0-c17b-5360-69f7-8d1428960258@gmail.com>
 <4d5b031e-3d0a-624f-1285-9540a9dc4716@mellanox.com>
 <a4335a01-a98b-573c-9747-b4039188340c@gmail.com>
 <ee012822-1080-fb83-bd8a-72053162d359@mellanox.com>
 <f5bd669b-6a0f-46e9-97b9-7abe73a228a5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa <roopa@cumulusnetworks.com>,
        Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:33762 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751191AbdH2HzR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 03:55:17 -0400
Received: by mail-wr0-f172.google.com with SMTP id k94so7687905wrc.0
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 00:55:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <f5bd669b-6a0f-46e9-97b9-7abe73a228a5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 29, 2017 at 04:57:12AM CEST, dsahern@gmail.com wrote:
>On 8/27/17 2:31 AM, Arkadi Sharshevsky wrote:
>>> Also, this dpipe capability seems to be just dumping data structures
>>> maintained by the driver. ie., you can compare the mlxsw view of
>>> networking state to IPv4 and IPv6 level tables. Any plans to offer a
>>> command that reads data from the h/w and passes that back to the user?
>>> i.e, a command to compare kernel tables to h/w state?
>>>
>> 
>> So this infra should provide several things-
>> 
>> 1) Reveal the interactions between various hardware tables
>> 2) Counters for this tables
>> 3) Debugabillity
>> 
>> The first two can be achieved right now. Regarding debugabillity, which
>> is a bit vague, the current assumption is that the drivers internal data
>> structures are synced with hardware (which is no always true), and maybe
>> are not synced with the kernel, so this can be achieved right now by
>> dumping the internal state of the driver. Furthermore, the counters are
>> dumped from the hardware and give the user additional indication.
>> 
>> I completely agree that the hardware should be dumped in order to
>> validate the internal data structures are really synced with HW. This
>> could be usable for observing data corruptions inside the ASIC and
>> various complex bugs.
>> 
>> In order to address that I though about maybe add a flag called
>> "validate_hw" so that during the dump the driver<-->hw state could be
>> validated.
>> 
>> What do you think about it?
>
>It is not just a matter of dumping hardware state. The data returned by
>dump needs to be consistent across platforms and vendors.
>
>If the intent is validating hardware state matches kernel state (ie.,

Nope, that is definitelly not the intent. The intent is to provide user
some more information about how the actual tables in hw look like, so he
knows exactly what is going on there and eventually can optimize things
if needed (resource allocations for example)


>h/w forwarding matches s/w forwarding), then the hardware state should
>be dumped by the driver in a form that parallels kernel state. e.g.,
>dump h/w routes, neighbor entries, fdb's in a form and granularity
>similar to what is done for kernel tables.
>
>With the recent dpipe changes that allows kernel to driver cache and
>kernel to h/w state comparisons.
