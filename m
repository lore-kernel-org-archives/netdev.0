From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 17/17] rocker: add ndo_bridge_setlnk/getlink
 support for learning policy
Date: Wed, 26 Nov 2014 12:27:18 +0100
Message-ID: <20141126112718.GK1875@nanopsycho.orion>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-18-git-send-email-jiri@resnulli.us>
 <20141126110709.GC4321@casper.infradead.org>
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
Received: from mail-wi0-f181.google.com ([209.85.212.181]:60369 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbaKZL1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 06:27:21 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so4619645wiv.2
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 03:27:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141126110709.GC4321@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 26, 2014 at 12:07:09PM CET, tgraf@suug.ch wrote:
>On 11/25/14 at 11:28am, Jiri Pirko wrote:
>> @@ -3657,6 +3693,64 @@ skip:
>>  	return idx;
>>  }
>>  
>> +static int rocker_port_bridge_setlink(struct net_device *dev,
>> +				      struct nlmsghdr *nlh)
>> +{
>> +	struct rocker_port *rocker_port = netdev_priv(dev);
>> +	struct nlattr *protinfo;
>> +	struct nlattr *afspec;
>> +	struct nlattr *attr;
>> +	u16 mode;
>> +	int err;
>> +
>> +	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
>> +				   IFLA_PROTINFO);
>> +	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
>> +
>> +	if (afspec) {
>> +		attr = nla_find_nested(afspec, IFLA_BRIDGE_MODE);
>> +		if (attr) {
>> +			mode = nla_get_u16(attr);
>> +			if (mode != BRIDGE_MODE_SWDEV)
>> +				return -EINVAL;
>> +		}
>> +	}
>
>The Netlink message is completely unverified at this point. All
>rtnl_bridge_setlink() does is verify that msgsize >= ifinfomsg.
>All of the drivers but br_setlink() need fixing in this regard.

I believe that we should fix this for all drivers in a follow-up patch.
