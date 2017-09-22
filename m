From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [patch net-next 07/12] mlxsw: spectrum: Add the multicast routing
 offloading logic
Date: Fri, 22 Sep 2017 11:36:59 +0300
Message-ID: <a6852db1-76a2-b4f3-c558-cd4cc0a1309b@mellanox.com>
References: <20170921064338.1282-1-jiri@resnulli.us>
 <20170921064338.1282-8-jiri@resnulli.us> <20170921152654.GF27589@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        mlxsw@mellanox.com
To: Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0085.outbound.protection.outlook.com ([104.47.1.85]:23720
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751792AbdIVIhH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 04:37:07 -0400
In-Reply-To: <20170921152654.GF27589@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/2017 06:26 PM, Andrew Lunn wrote:
>> +static void mlxsw_sp_mr_route_stats_update(struct mlxsw_sp *mlxsw_sp,
>> +					   struct mlxsw_sp_mr_route *mr_route)
>> +{
>> +	struct mlxsw_sp_mr *mr = mlxsw_sp->mr;
>> +	u64 packets, bytes;
>> +
>> +	if (mr_route->route_action == MLXSW_SP_MR_ROUTE_ACTION_TRAP)
>> +		return;
>> +
>> +	mr->mr_ops->route_stats(mlxsw_sp, mr_route->route_priv, &packets,
>> +				&bytes);
>> +
>> +	switch (mr_route->mr_table->proto) {
>> +	case MLXSW_SP_L3_PROTO_IPV4:
>> +		mr_route->mfc4->mfc_un.res.pkt = packets;
>> +		mr_route->mfc4->mfc_un.res.bytes = bytes;
> What about wrong_if and lastuse? 

wronf_if is updated by ipmr as it is trapped to the CPU. We did not
address lastuse currently, though it can be easily addressed here.

>
> Is an mfc with iif on the host, not the switch, not offloaded?


I am not sure I followed. What do you mean MFC with iif on the host? you mean
MFC with iif that is an external NIC which is not part of the spectrum ASIC? in
this case, the route will not be offloaded and all traffic will pass in slowpath.


>
>    Andrew
