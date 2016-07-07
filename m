From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [iproute PATCH 0/2] Netns performance improvements
Date: Thu, 7 Jul 2016 09:16:20 -0700
Message-ID: <577E8054.6040603@hpe.com>
References: <1467729773-16751-1-git-send-email-phil@nwl.cc>
 <87twg4ywjz.fsf@x220.int.ebiederm.org> <20160705205103.GE620@orbyte.nwl.cc>
 <87h9c259ip.fsf@x220.int.ebiederm.org> <20160707111718.GL620@orbyte.nwl.cc>
 <577E5244.8030601@6wind.com> <20160707154809.GN620@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Phil Sutter <phil@nwl.cc>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <shemming@brocade.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2354.austin.hpe.com ([15.233.44.27]:13004 "EHLO
	g2t2354.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbcGGQQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 12:16:28 -0400
In-Reply-To: <20160707154809.GN620@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/2016 08:48 AM, Phil Sutter wrote:
> On Thu, Jul 07, 2016 at 02:59:48PM +0200, Nicolas Dichtel wrote:
>> Le 07/07/2016 13:17, Phil Sutter a =C3=A9crit :
>> [snip]
>>> The issue came up during OpenStack Neutron testing, see this ticket=
 for
>>> reference:
>>>
>>> https://bugzilla.redhat.com/show_bug.cgi?id=3D1310795
>> Access to this ticket is not public :(
>
> *Sigh* OK, here are a few quotes:
>
> "OpenStack Neutron controller nodes, when undergoing testing, are
> locking up specifically during creation and mounting of namespaces.
> They appear to be blocking behind vfsmount_lock, and contention for t=
he
> namespace_sem"
>
> "During the scale testing, we have 300 routers, 600 dhcp namespaces
> spread across four neutron network nodes. When then start as one set =
of
> standard Openstack Rally benchmark test cycle against neutron. An
> example scenario is creating 10x networks, list them, delete them and
> repeat 10x times. The second set performs an L3 benchmark test betwee=
n
> two instances."
>

Those 300 routers will each have at least one namespace along with the=20
dhcp namespaces.  Depending on the nature of the routers (Distributed=20
versus Centralized Virtual Routers - DVR vs CVR) and whether the router=
s=20
are supposed to be "HA" there can be more than one namespace for a give=
n=20
router.

300 routers is far from the upper limit/goal.  Back in HP Public Cloud,=
=20
we were running as many as 700 routers per network node (*), and more=20
than four network nodes. (back then it was just the one namespace per=20
router and network). Mileage will of course vary based on the "oomph" o=
f=20
one's network node(s).

happy benchmarking,

rick jones

* Didn't want to go much higher than that because each router had a por=
t=20
on a common linux bridge and getting to > 1024 would be an unpleasant d=
ay.
