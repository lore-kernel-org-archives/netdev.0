From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v2 07/10] bridge: call netdev_sw_port_stp_update
 when bridge port STP status changes
Date: Mon, 10 Nov 2014 07:59:21 -0800
Message-ID: <5460E0D9.9070909@cumulusnetworks.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-8-git-send-email-jiri@resnulli.us> <5460B989.8030404@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:34687 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807AbaKJP7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 10:59:40 -0500
In-Reply-To: <5460B989.8030404@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14, 5:11 AM, Jamal Hadi Salim wrote:
> On 11/09/14 05:51, Jiri Pirko wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> To notify switch driver of change in STP state of bridge port, add new
>> .ndo op and provide swdev wrapper func to call ndo op. Use it in bridge
>> code then.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>   include/linux/netdevice.h |  6 ++++++
>>   include/net/switchdev.h   |  6 ++++++
>>   net/bridge/br_netlink.c   |  2 ++
>>   net/bridge/br_stp.c       |  4 ++++
>>   net/bridge/br_stp_if.c    |  3 +++
>>   net/bridge/br_stp_timer.c |  2 ++
>>   net/switchdev/switchdev.c | 19 +++++++++++++++++++
>>   7 files changed, 42 insertions(+)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 116a19d..35f21a95 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -1033,6 +1033,10 @@ typedef u16 (*select_queue_fallback_t)(struct 
>> net_device *dev,
>>    *                  const unsigned char *addr,
>>    *                  u16 vid);
>>    *    Called to delete a fdb from switch device port.
>> + *
>> + * int (*ndo_sw_port_stp_update)(struct net_device *dev, u8 state);
>> + *    Called to notify switch device port of bridge port STP
>> + *    state change.
>
> You are unconditionally calling
> netdev_sw_port_stp_update(p->dev, p->state);
> Again issue is policy. Could you make this work the same
> way the fdb_add e.g user intent of whether i want to turn
> a port in hardware and/or software to disabled/learning/etc
> is reflected?
>
> btw: does _sw_ stand for switch? why not _hw_ ?
> Could we have one ndo for all flags instead of individual ones.

I agree. There is the bridge port state and a bunch of bridge port 
flags. A generic ndo will be good.
>
> I know the current user space code uses u8 as a bitflag; but
> maybe we can introduce a new u32 flag bitmask that has all the
> flags set for backward compat? I can count about a total of 10.
