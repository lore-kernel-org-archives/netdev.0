From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 11/12] mlxsw: spectrum_dpipe: Add support for
 IPv4 host table dump
Date: Fri, 25 Aug 2017 12:51:31 -0700
Message-ID: <a4335a01-a98b-573c-9747-b4039188340c@gmail.com>
References: <20170824064010.1646-1-jiri@resnulli.us>
 <20170824064010.1646-12-jiri@resnulli.us>
 <e5af97b0-c17b-5360-69f7-8d1428960258@gmail.com>
 <4d5b031e-3d0a-624f-1285-9540a9dc4716@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>,
        Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33153 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932424AbdHYTvd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 15:51:33 -0400
Received: by mail-pg0-f67.google.com with SMTP id q16so1073685pgc.0
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 12:51:33 -0700 (PDT)
In-Reply-To: <4d5b031e-3d0a-624f-1285-9540a9dc4716@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/25/17 2:26 AM, Arkadi Sharshevsky wrote:
> 
> 
> On 08/24/2017 10:26 PM, David Ahern wrote:
>> On 8/23/17 11:40 PM, Jiri Pirko wrote:
>>> +static int
>>> +mlxsw_sp_dpipe_table_host_entries_get(struct mlxsw_sp *mlxsw_sp,
>>> +				      struct devlink_dpipe_entry *entry,
>>> +				      bool counters_enabled,
>>> +				      struct devlink_dpipe_dump_ctx *dump_ctx,
>>> +				      int type)
>>> +{
>>> +	int rif_neigh_count = 0;
>>> +	int rif_neigh_skip = 0;
>>> +	int neigh_count = 0;
>>> +	int rif_count;
>>> +	int i, j;
>>> +	int err;
>>> +
>>> +	rtnl_lock();
>>
>> Why does a h/w driver dumping its tables need the rtnl lock?
>>
> 
> This table represents the hw IPv4 arp table, and the
> driver depends on rtnl to be held.
> 

Meaning mlxsw does not have its own locks protecting data structures --
e.g., rif adds and deletes, so it is relying on rtnl?

Also, this dpipe capability seems to be just dumping data structures
maintained by the driver. ie., you can compare the mlxsw view of
networking state to IPv4 and IPv6 level tables. Any plans to offer a
command that reads data from the h/w and passes that back to the user?
i.e, a command to compare kernel tables to h/w state?
