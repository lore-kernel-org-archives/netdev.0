From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [iproute PATCH 0/2] Netns performance improvements
Date: Fri, 8 Jul 2016 10:01:13 +0200
Message-ID: <577F5DC9.7020303@6wind.com>
References: <1467729773-16751-1-git-send-email-phil@nwl.cc>
 <87twg4ywjz.fsf@x220.int.ebiederm.org> <20160705205103.GE620@orbyte.nwl.cc>
 <87h9c259ip.fsf@x220.int.ebiederm.org> <20160707111718.GL620@orbyte.nwl.cc>
 <577E5244.8030601@6wind.com> <20160707154809.GN620@orbyte.nwl.cc>
 <577E8054.6040603@hpe.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Rick Jones <rick.jones2@hpe.com>, Phil Sutter <phil@nwl.cc>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <shemming@brocade.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37562 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbcGHIBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 04:01:16 -0400
Received: by mail-wm0-f45.google.com with SMTP id k123so7592764wme.0
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 01:01:15 -0700 (PDT)
In-Reply-To: <577E8054.6040603@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/07/2016 18:16, Rick Jones a =C3=A9crit :
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
>=20
> Those 300 routers will each have at least one namespace along with th=
e dhcp
> namespaces.  Depending on the nature of the routers (Distributed vers=
us
> Centralized Virtual Routers - DVR vs CVR) and whether the routers are=
 supposed
> to be "HA" there can be more than one namespace for a given router.
>=20
> 300 routers is far from the upper limit/goal.  Back in HP Public Clou=
d, we were
> running as many as 700 routers per network node (*), and more than fo=
ur network
> nodes. (back then it was just the one namespace per router and networ=
k). Mileage
> will of course vary based on the "oomph" of one's network node(s).
Thank you for the details.

Do you have a script or something else to easily reproduce this problem=
?
