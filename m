From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 16/17] bridge: add brport flags to dflt
 bridge_getlink
Date: Wed, 26 Nov 2014 10:25:12 +0100
Message-ID: <20141126092512.GE1875@nanopsycho.orion>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-17-git-send-email-jiri@resnulli.us>
 <20141125220753.GD3912@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:59130 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbaKZJZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 04:25:14 -0500
Received: by mail-wi0-f176.google.com with SMTP id ex7so11826889wid.3
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 01:25:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141125220753.GD3912@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 25, 2014 at 11:07:53PM CET, tgraf@suug.ch wrote:
>On 11/25/14 at 11:28am, Jiri Pirko wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>> 
>> To allow brport device to return current brport flags set on port.  Add
>> returned flags to nested IFLA_PROTINFO netlink msg built in dflt getlink.
>> With this change, netlink msg returned for bridge_getlink contains the port's
>> offloaded flag settings (the port's SELF settings).
>> 
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Minor nit below. Otherwise:
>
>Acked-by: Thomas Graf <tgraf@suug.ch>
>
>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index bd5e783..91e5368 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -2687,12 +2687,22 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
>>  	return skb->len;
>>  }
>>  
>> +static int brport_nla_put_flag(struct sk_buff *skb, u32 flags, u32 mask,
>> +			       unsigned int attrnum, unsigned int flag)
>> +{
>> +	if (mask & flag)
>> +		return nla_put_u8(skb, attrnum, !!(flags & flag));
>
>nla_put_flag()?

No, that is not the same. nla_put_flag works differently. The attr is
either present or not. But in this case, attr is always present and has
value of either 0 or 1.

>
