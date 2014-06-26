From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/2] openvswitch: introduce rtnl ops stub
Date: Thu, 26 Jun 2014 09:39:36 +0200
Message-ID: <20140626073936.GA3049@minipsycho.orion>
References: <1403699280-12837-1-git-send-email-jiri@resnulli.us>
 <1403699280-12837-2-git-send-email-jiri@resnulli.us>
 <87fvitvuxp.fsf@x220.int.ebiederm.org>
 <20140625163509.GC2972@minipsycho.orion>
 <877g44x68q.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pshelar@nicira.com,
	cwang@twopensource.com, nicolas.dichtel@6wind.com,
	david@gibson.dropbear.id.au, sfeldma@cumulusnetworks.com,
	sucheta.chakraborty@qlogic.com, stephen@networkplumber.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:49881 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754865AbaFZHjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 03:39:39 -0400
Received: by mail-we0-f177.google.com with SMTP id u56so3155078wes.22
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 00:39:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <877g44x68q.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 25, 2014 at 07:13:09PM CEST, ebiederm@xmission.com wrote:
>Jiri Pirko <jiri@resnulli.us> writes:
>
>> Wed, Jun 25, 2014 at 06:02:42PM CEST, ebiederm@xmission.com wrote:
>>>Jiri Pirko <jiri@resnulli.us> writes:
>>>
>>>> This stub now allows userspace to see IFLA_INFO_KIND for ovs master and
>>>> IFLA_INFO_SLAVE_KIND for slave.
>>>
>>>I am puzzled why you don't implement full rtnl_link_operations support.
>>
>> openvswitch does not need that at the moment (most probably it never
>> will). Creation and deletion is handled over separate genl channel.
>>
>>>
>>>If all you want is to report which kind of driver you have I suspect
>>>implementing ethtool_ops.get_drvinfo is a much better fit.
>>
>> That is maybe partly true but that would not be consistent with bond, team,
>> bridge masters and slaves which benefit ops->kind to expose the type
>> into userspace.
>
>So instead of using the mechanism that is supported by most of the
>network drivers in the tree you are instead relying on a mechanism
>that only works for a handful of software defined network devices.

As I said, I just want openvswitch to be similar in this with
bridge/bond/team. ops->kind is there, its exposed to userspace, I don't
see any harm adding one another code which benefits that.

Note that this also allows to see slave kind.

>
>I really think exposing a kind at this point is lying to user space
>as having a kind implies that the netlink messages behind "ip link add"
>and "ip link del" work.

Proper -EOPNOTSUPP is returned. And is is the same as if !ops. The
behavior is not changed.

>
>Further I have seen nothing in what you are proposing that addresses
>that absolute horrible maintenance consequences of your patch.

I don't understand what maintenance consequences you have on mind. Would
you please exmplain? Thanks.

>
>Eric
