From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net] switchdev: bridge: Pass ageing time as clock_t
 instead of jiffies
Date: Mon, 21 Dec 2015 18:50:38 +0200
Message-ID: <20151221165021.GA22302@colbert.mtl.com>
References: <1450688161-4792-1-git-send-email-jiri@resnulli.us>
 <5678206F.8050104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jiri Pirko <jiri@resnulli.us>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <eladr@mellanox.com>, <yotamg@mellanox.com>,
	<stephen@networkplumber.org>, Jiri Pirko <jiri@mellanox.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0093.outbound.protection.outlook.com ([157.55.234.93]:7084
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751314AbbLURHE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Dec 2015 12:07:04 -0500
Content-Disposition: inline
In-Reply-To: <5678206F.8050104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Dec 21, 2015 at 05:53:19PM IST, dsahern@gmail.com wrote:
>On 12/21/15 3:56 AM, Jiri Pirko wrote:
>> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
>> index 5396ff08..12045de 100644
>> --- a/net/bridge/br_stp_if.c
>> +++ b/net/bridge/br_stp_if.c
>> @@ -39,7 +39,7 @@ void br_init_port(struct net_bridge_port *p)
>>   	struct switchdev_attr attr = {
>>   		.id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
>>   		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP | SWITCHDEV_F_DEFER,
>> -		.u.ageing_time = p->br->ageing_time,
>> +		.u.ageing_time = jiffies_to_clock_t(p->br->ageing_time),
>>   	};
>>   	int err;
>
>
>ageing_time is a u32; clock_t is a long.

Hi,

p->br->ageing_time is set in br_set_ageing_time, where it's converted to
jiffies from clock_t, that is treated as u32.
