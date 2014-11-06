From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 07/10] bridge: call netdev_sw_port_stp_update
 when bridge port STP status changes
Date: Thu, 6 Nov 2014 10:57:23 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1411061056540.24819@rocker1.rocker.net>
References: <1415265610-9338-1-git-send-email-jiri@resnulli.us> <1415265610-9338-8-git-send-email-jiri@resnulli.us> <545BA8EF.4060601@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:55098 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbaKFS5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 13:57:12 -0500
Received: by mail-pd0-f173.google.com with SMTP id v10so1676628pde.4
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 10:57:11 -0800 (PST)
In-Reply-To: <545BA8EF.4060601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 6 Nov 2014, Florian Fainelli wrote:

> On 11/06/2014 01:20 AM, Jiri Pirko wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> To notify switch driver of change in STP state of bridge port, add new
>> .ndo op and provide swdev wrapper func to call ndo op. Use it in bridge
>> code then.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>
> [snip]
>
>>  #endif /* _LINUX_SWITCHDEV_H_ */
>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index 86c239b..13fecf1 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -17,6 +17,7 @@
>>  #include <net/net_namespace.h>
>>  #include <net/sock.h>
>>  #include <uapi/linux/if_bridge.h>
>> +#include <net/switchdev.h>
>>
>>  #include "br_private.h"
>>  #include "br_private_stp.h"
>> @@ -304,6 +305,7 @@ static int br_set_port_state(struct net_bridge_port *p, u8 state)
>>
>>  	br_set_state(p, state);
>>  	br_log_state(p);
>> +	netdev_sw_port_stp_update(p->dev, p->state);
>
> Is there a reason netdev_sw_port_stp_update() is not folded in
> br_set_state()? Are we missing calls to br_set_state() in some locations?

I put the netdev_sw call at the same level as br_log_state() and 
br_ifinfo_notify(), but now that you bring up the question, I agree it 
would be cleaner/safer if netdev_sw call was from br_set_state().

> --
> Florian
>
