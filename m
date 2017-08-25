From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [patch net-next 11/12] mlxsw: spectrum_dpipe: Add support for
 IPv4 host table dump
Date: Fri, 25 Aug 2017 12:26:39 +0300
Message-ID: <4d5b031e-3d0a-624f-1285-9540a9dc4716@mellanox.com>
References: <20170824064010.1646-1-jiri@resnulli.us>
 <20170824064010.1646-12-jiri@resnulli.us>
 <e5af97b0-c17b-5360-69f7-8d1428960258@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: David Ahern <dsahern@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0070.outbound.protection.outlook.com ([104.47.0.70]:50920
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755136AbdHYJ0t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 05:26:49 -0400
In-Reply-To: <e5af97b0-c17b-5360-69f7-8d1428960258@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/24/2017 10:26 PM, David Ahern wrote:
> On 8/23/17 11:40 PM, Jiri Pirko wrote:
>> +static int
>> +mlxsw_sp_dpipe_table_host_entries_get(struct mlxsw_sp *mlxsw_sp,
>> +				      struct devlink_dpipe_entry *entry,
>> +				      bool counters_enabled,
>> +				      struct devlink_dpipe_dump_ctx *dump_ctx,
>> +				      int type)
>> +{
>> +	int rif_neigh_count = 0;
>> +	int rif_neigh_skip = 0;
>> +	int neigh_count = 0;
>> +	int rif_count;
>> +	int i, j;
>> +	int err;
>> +
>> +	rtnl_lock();
> 
> Why does a h/w driver dumping its tables need the rtnl lock?
> 

This table represents the hw IPv4 arp table, and the
driver depends on rtnl to be held.
