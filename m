From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: remove the unnecessary statement in find_match()
Date: Thu, 31 Oct 2013 00:22:34 -0400 (EDT)
Message-ID: <20131031.002234.45924350853188128.davem@davemloft.net>
References: <5270B7AE.9020801@cn.fujitsu.com>
	<20131030.170837.1882918923249091614.davem@davemloft.net>
	<20131030211157.GA13902@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: duanj.fnst@cn.fujitsu.com, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36668 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab3JaEWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 00:22:37 -0400
In-Reply-To: <20131030211157.GA13902@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 30 Oct 2013 22:11:57 +0100

> On Wed, Oct 30, 2013 at 05:08:37PM -0400, David Miller wrote:
>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>> Date: Wed, 30 Oct 2013 15:39:26 +0800
>> 
>> > 
>> > After reading the function rt6_check_neigh(), we can
>> > know that the RT6_NUD_FAIL_SOFT can be returned only
>> > when the IS_ENABLE(CONFIG_IPV6_ROUTER_PREF) is false.
>> > so in function find_match(), there is no need to execute
>> > the statement !IS_ENABLED(CONFIG_IPV6_ROUTER_PREF).
>> > 
>> > Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>> 
>> Applied to net-next, thanks.
>> 
>> CONFIG_IPV6_ROUTER_PREF is another good candidate for Kconfig
>> removal.  I know we've had several bugs that only apply when
>> this option is on vs. off.  We're maintaining two different
>> code paths, for really no good reason.
> 
> I agree and actually thought about that yesterday. Do you think a sysctl
> is a good option?

Every distribution ships with the Kconfig option on, and no sysctl
exists currently to control it.

So I'd say it's not necessary at all, or at the very least let's have
someone come forward with a real rather than theoretical use case for
such a feature before adding it.

Actually, if RFC 4191 has the usual language like "there SHOULD be
an administrative mechanism to disable blah blah blah" I could
be convinced to add it now.  Can someone take a look?

Either way it'd probably be a per-inet6_dev option, right?
