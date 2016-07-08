From: Brian Haley <brian.haley@hpe.com>
Subject: Re: [iproute PATCH 0/2] Netns performance improvements
Date: Fri, 8 Jul 2016 10:31:45 -0400
Message-ID: <577FB951.2010309@hpe.com>
References: <1467729773-16751-1-git-send-email-phil@nwl.cc>
 <87twg4ywjz.fsf@x220.int.ebiederm.org> <20160705205103.GE620@orbyte.nwl.cc>
 <87h9c259ip.fsf@x220.int.ebiederm.org> <20160707111718.GL620@orbyte.nwl.cc>
 <577E5244.8030601@6wind.com> <20160707154809.GN620@orbyte.nwl.cc>
 <577E8054.6040603@hpe.com> <87vb0h1k6b.fsf@x220.int.ebiederm.org>
 <577E914F.3060001@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Stephen Hemminger <shemming@brocade.com>,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hpe.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hpe.com ([15.233.16.89]:7788 "EHLO
	g2t1383g.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754180AbcGHObu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 10:31:50 -0400
Received: from g4t3425.houston.hpe.com (g4t3425.houston.hpe.com [15.241.140.78])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hpe.com (Postfix) with ESMTPS id 71BE64FA
	for <netdev@vger.kernel.org>; Fri,  8 Jul 2016 14:31:49 +0000 (UTC)
In-Reply-To: <577E914F.3060001@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/2016 01:28 PM, Rick Jones wrote:
> On 07/07/2016 09:34 AM, Eric W. Biederman wrote:
>> Rick Jones <rick.jones2@hpe.com> writes:
>>> 300 routers is far from the upper limit/goal.  Back in HP Public
>>> Cloud, we were running as many as 700 routers per network node (*),
>>> and more than four network nodes. (back then it was just the one
>>> namespace per router and network). Mileage will of course vary based
>>> on the "oomph" of one's network node(s).
>>
>> To clarify processes for these routers and dhcp servers are created
>> with "ip netns exec"?
>
> I believe so, but it would be good to have someone else confirm that, and speak
> to your paragraph below.

Yes, the namespace is created and configured, then in the case of dhcp an 'ip 
netns exec $namespace dnsmasq ...' is run.  Routers typically have a small 
daemon running "inside" as well.

>> If that is the case and you are using this feature as effectively a
>> lightweight container and not lots vrfs in a single network stack
>> then I suspect much larger gains can be had by creating a variant
>> of ip netns exec avoids the mount propagation.

So you're thinking a new command like 'ip netns daemon $namespace ...' ?  Or if 
there's a better way with other tools today to accomplish this I'd be 
interested, as waiting for a new iproute2 to ripple through the distros could 
take a while.

-Brian
