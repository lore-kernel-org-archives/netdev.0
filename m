From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [iproute PATCH 0/2] Netns performance improvements
Date: Thu, 7 Jul 2016 10:28:47 -0700
Message-ID: <577E914F.3060001@hpe.com>
References: <1467729773-16751-1-git-send-email-phil@nwl.cc>
 <87twg4ywjz.fsf@x220.int.ebiederm.org> <20160705205103.GE620@orbyte.nwl.cc>
 <87h9c259ip.fsf@x220.int.ebiederm.org> <20160707111718.GL620@orbyte.nwl.cc>
 <577E5244.8030601@6wind.com> <20160707154809.GN620@orbyte.nwl.cc>
 <577E8054.6040603@hpe.com> <87vb0h1k6b.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Stephen Hemminger <shemming@brocade.com>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2353.austin.hpe.com ([15.233.44.26]:46946 "EHLO
	g2t2353.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588AbcGGR2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 13:28:49 -0400
In-Reply-To: <87vb0h1k6b.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/2016 09:34 AM, Eric W. Biederman wrote:
> Rick Jones <rick.jones2@hpe.com> writes:
>> 300 routers is far from the upper limit/goal.  Back in HP Public
>> Cloud, we were running as many as 700 routers per network node (*),
>> and more than four network nodes. (back then it was just the one
>> namespace per router and network). Mileage will of course vary based
>> on the "oomph" of one's network node(s).
>
> To clarify processes for these routers and dhcp servers are created
> with "ip netns exec"?

I believe so, but it would be good to have someone else confirm that, 
and speak to your paragraph below.

> If that is the case and you are using this feature as effectively a
> lightweight container and not lots vrfs in a single network stack
> then I suspect much larger gains can be had by creating a variant
> of ip netns exec avoids the mount propagation.
>

...

>> * Didn't want to go much higher than that because each router had a
>> port on a common linux bridge and getting to > 1024 would be an
>> unpleasant day.
>
> * I would have thought all you have to do is bump of the size
>    of the linux neighbour cache.  echo $BIGNUM > /proc/sys/net/ipv4/neigh/default/gc_thresh3

We didn't want to hit the 1024 port limit of a (then?) Linux bridge.

rick

Having a bit of deja vu but I suspect things like commit 
0818bf27c05b2de56c5b2bd08cfae2a939bd5f52  are not exactly on the same 
wavelength, just my brain seeing "namespaces" and "performance" and 
lighting-up :)
