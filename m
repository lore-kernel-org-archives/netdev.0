From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 11/12] mlxsw: spectrum_dpipe: Add support for
 IPv4 host table dump
Date: Mon, 28 Aug 2017 20:57:12 -0600
Message-ID: <f5bd669b-6a0f-46e9-97b9-7abe73a228a5@gmail.com>
References: <20170824064010.1646-1-jiri@resnulli.us>
 <20170824064010.1646-12-jiri@resnulli.us>
 <e5af97b0-c17b-5360-69f7-8d1428960258@gmail.com>
 <4d5b031e-3d0a-624f-1285-9540a9dc4716@mellanox.com>
 <a4335a01-a98b-573c-9747-b4039188340c@gmail.com>
 <ee012822-1080-fb83-bd8a-72053162d359@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa <roopa@cumulusnetworks.com>,
        Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>,
        Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:37681 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751211AbdH2C5O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 22:57:14 -0400
Received: by mail-pg0-f54.google.com with SMTP id 83so6846795pgb.4
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 19:57:14 -0700 (PDT)
In-Reply-To: <ee012822-1080-fb83-bd8a-72053162d359@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/27/17 2:31 AM, Arkadi Sharshevsky wrote:
>> Also, this dpipe capability seems to be just dumping data structures
>> maintained by the driver. ie., you can compare the mlxsw view of
>> networking state to IPv4 and IPv6 level tables. Any plans to offer a
>> command that reads data from the h/w and passes that back to the user?
>> i.e, a command to compare kernel tables to h/w state?
>>
> 
> So this infra should provide several things-
> 
> 1) Reveal the interactions between various hardware tables
> 2) Counters for this tables
> 3) Debugabillity
> 
> The first two can be achieved right now. Regarding debugabillity, which
> is a bit vague, the current assumption is that the drivers internal data
> structures are synced with hardware (which is no always true), and maybe
> are not synced with the kernel, so this can be achieved right now by
> dumping the internal state of the driver. Furthermore, the counters are
> dumped from the hardware and give the user additional indication.
> 
> I completely agree that the hardware should be dumped in order to
> validate the internal data structures are really synced with HW. This
> could be usable for observing data corruptions inside the ASIC and
> various complex bugs.
> 
> In order to address that I though about maybe add a flag called
> "validate_hw" so that during the dump the driver<-->hw state could be
> validated.
> 
> What do you think about it?

It is not just a matter of dumping hardware state. The data returned by
dump needs to be consistent across platforms and vendors.

If the intent is validating hardware state matches kernel state (ie.,
h/w forwarding matches s/w forwarding), then the hardware state should
be dumped by the driver in a form that parallels kernel state. e.g.,
dump h/w routes, neighbor entries, fdb's in a form and granularity
similar to what is done for kernel tables.

With the recent dpipe changes that allows kernel to driver cache and
kernel to h/w state comparisons.
