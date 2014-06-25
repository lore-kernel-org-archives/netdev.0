From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch net-next 2/2] openvswitch: introduce rtnl ops stub
Date: Wed, 25 Jun 2014 10:13:09 -0700
Message-ID: <877g44x68q.fsf@x220.int.ebiederm.org>
References: <1403699280-12837-1-git-send-email-jiri@resnulli.us>
	<1403699280-12837-2-git-send-email-jiri@resnulli.us>
	<87fvitvuxp.fsf@x220.int.ebiederm.org>
	<20140625163509.GC2972@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, pshelar@nicira.com,
	cwang@twopensource.com, nicolas.dichtel@6wind.com,
	david@gibson.dropbear.id.au, sfeldma@cumulusnetworks.com,
	sucheta.chakraborty@qlogic.com, stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42014 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757408AbaFYRQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 13:16:27 -0400
In-Reply-To: <20140625163509.GC2972@minipsycho.orion> (Jiri Pirko's message of
	"Wed, 25 Jun 2014 18:35:09 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> writes:

> Wed, Jun 25, 2014 at 06:02:42PM CEST, ebiederm@xmission.com wrote:
>>Jiri Pirko <jiri@resnulli.us> writes:
>>
>>> This stub now allows userspace to see IFLA_INFO_KIND for ovs master and
>>> IFLA_INFO_SLAVE_KIND for slave.
>>
>>I am puzzled why you don't implement full rtnl_link_operations support.
>
> openvswitch does not need that at the moment (most probably it never
> will). Creation and deletion is handled over separate genl channel.
>
>>
>>If all you want is to report which kind of driver you have I suspect
>>implementing ethtool_ops.get_drvinfo is a much better fit.
>
> That is maybe partly true but that would not be consistent with bond, team,
> bridge masters and slaves which benefit ops->kind to expose the type
> into userspace.

So instead of using the mechanism that is supported by most of the
network drivers in the tree you are instead relying on a mechanism
that only works for a handful of software defined network devices.

I really think exposing a kind at this point is lying to user space
as having a kind implies that the netlink messages behind "ip link add"
and "ip link del" work.

Further I have seen nothing in what you are proposing that addresses
that absolute horrible maintenance consequences of your patch.

Eric
