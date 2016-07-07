From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [iproute PATCH 0/2] Netns performance improvements
Date: Thu, 07 Jul 2016 11:34:36 -0500
Message-ID: <87vb0h1k6b.fsf@x220.int.ebiederm.org>
References: <1467729773-16751-1-git-send-email-phil@nwl.cc>
	<87twg4ywjz.fsf@x220.int.ebiederm.org>
	<20160705205103.GE620@orbyte.nwl.cc>
	<87h9c259ip.fsf@x220.int.ebiederm.org>
	<20160707111718.GL620@orbyte.nwl.cc> <577E5244.8030601@6wind.com>
	<20160707154809.GN620@orbyte.nwl.cc> <577E8054.6040603@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Phil Sutter <phil@nwl.cc>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Stephen Hemminger <shemming@brocade.com>,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:39511 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbcGGQrj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 12:47:39 -0400
In-Reply-To: <577E8054.6040603@hpe.com> (Rick Jones's message of "Thu, 7 Jul
	2016 09:16:20 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones <rick.jones2@hpe.com> writes:

> On 07/07/2016 08:48 AM, Phil Sutter wrote:
>> On Thu, Jul 07, 2016 at 02:59:48PM +0200, Nicolas Dichtel wrote:
>>> Le 07/07/2016 13:17, Phil Sutter a =C3=A9crit :
>>> [snip]
>>>> The issue came up during OpenStack Neutron testing, see this ticke=
t for
>>>> reference:
>>>>
>>>> https://bugzilla.redhat.com/show_bug.cgi?id=3D1310795
>>> Access to this ticket is not public :(
>>
>> *Sigh* OK, here are a few quotes:
>>
>> "OpenStack Neutron controller nodes, when undergoing testing, are
>> locking up specifically during creation and mounting of namespaces.
>> They appear to be blocking behind vfsmount_lock, and contention for =
the
>> namespace_sem"
>>
>> "During the scale testing, we have 300 routers, 600 dhcp namespaces
>> spread across four neutron network nodes. When then start as one set=
 of
>> standard Openstack Rally benchmark test cycle against neutron. An
>> example scenario is creating 10x networks, list them, delete them an=
d
>> repeat 10x times. The second set performs an L3 benchmark test betwe=
en
>> two instances."
>>
>
> Those 300 routers will each have at least one namespace along with th=
e
> dhcp namespaces.  Depending on the nature of the routers (Distributed
> versus Centralized Virtual Routers - DVR vs CVR) and whether the
> routers are supposed to be "HA" there can be more than one namespace
> for a given router.
>
> 300 routers is far from the upper limit/goal.  Back in HP Public
> Cloud, we were running as many as 700 routers per network node (*),
> and more than four network nodes. (back then it was just the one
> namespace per router and network). Mileage will of course vary based
> on the "oomph" of one's network node(s).

To clarify processes for these routers and dhcp servers are created
with "ip netns exec"?

If that is the case and you are using this feature as effectively a
lightweight container and not lots vrfs in a single network stack
then I suspect much larger gains can be had by creating a variant
of ip netns exec avoids the mount propagation.

> happy benchmarking,
>
> rick jones
>
> * Didn't want to go much higher than that because each router had a
> port on a common linux bridge and getting to > 1024 would be an
> unpleasant day.

* I would have thought all you have to do is bump of the size
  of the linux neighbour cache.  echo $BIGNUM > /proc/sys/net/ipv4/neig=
h/default/gc_thresh3=20

Eric
