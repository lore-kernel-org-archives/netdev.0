From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [patch net-next 11/12] mlxsw: spectrum_dpipe: Add support for
 IPv4 host table dump
Date: Sun, 27 Aug 2017 11:31:03 +0300
Message-ID: <ee012822-1080-fb83-bd8a-72053162d359@mellanox.com>
References: <20170824064010.1646-1-jiri@resnulli.us>
 <20170824064010.1646-12-jiri@resnulli.us>
 <e5af97b0-c17b-5360-69f7-8d1428960258@gmail.com>
 <4d5b031e-3d0a-624f-1285-9540a9dc4716@mellanox.com>
 <a4335a01-a98b-573c-9747-b4039188340c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: David Ahern <dsahern@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0057.outbound.protection.outlook.com ([104.47.0.57]:31184
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750830AbdH0IbN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 04:31:13 -0400
In-Reply-To: <a4335a01-a98b-573c-9747-b4039188340c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/25/2017 10:51 PM, David Ahern wrote:
> On 8/25/17 2:26 AM, Arkadi Sharshevsky wrote:
>>
>>
>> On 08/24/2017 10:26 PM, David Ahern wrote:
>>> On 8/23/17 11:40 PM, Jiri Pirko wrote:
>>>> +static int
>>>> +mlxsw_sp_dpipe_table_host_entries_get(struct mlxsw_sp *mlxsw_sp,
>>>> +				      struct devlink_dpipe_entry *entry,
>>>> +				      bool counters_enabled,
>>>> +				      struct devlink_dpipe_dump_ctx *dump_ctx,
>>>> +				      int type)
>>>> +{
>>>> +	int rif_neigh_count = 0;
>>>> +	int rif_neigh_skip = 0;
>>>> +	int neigh_count = 0;
>>>> +	int rif_count;
>>>> +	int i, j;
>>>> +	int err;
>>>> +
>>>> +	rtnl_lock();
>>>
>>> Why does a h/w driver dumping its tables need the rtnl lock?
>>>
>>
>> This table represents the hw IPv4 arp table, and the
>> driver depends on rtnl to be held.
>>
> 
> Meaning mlxsw does not have its own locks protecting data structures --
> e.g., rif adds and deletes, so it is relying on rtnl?
> 
> Also, this dpipe capability seems to be just dumping data structures
> maintained by the driver. ie., you can compare the mlxsw view of
> networking state to IPv4 and IPv6 level tables. Any plans to offer a
> command that reads data from the h/w and passes that back to the user?
> i.e, a command to compare kernel tables to h/w state?
> 

So this infra should provide several things-

1) Reveal the interactions between various hardware tables
2) Counters for this tables
3) Debugabillity

The first two can be achieved right now. Regarding debugabillity, which
is a bit vague, the current assumption is that the drivers internal data
structures are synced with hardware (which is no always true), and maybe
are not synced with the kernel, so this can be achieved right now by
dumping the internal state of the driver. Furthermore, the counters are
dumped from the hardware and give the user additional indication.

I completely agree that the hardware should be dumped in order to
validate the internal data structures are really synced with HW. This
could be usable for observing data corruptions inside the ASIC and
various complex bugs.

In order to address that I though about maybe add a flag called
"validate_hw" so that during the dump the driver<-->hw state could be
validated.

What do you think about it?

Thanks,
Arkadi
