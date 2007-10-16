From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: Resend: [IPROUTE2 PATCH] Interface group as new ip link option
Date: Tue, 16 Oct 2007 13:47:15 +0200
Message-ID: <4714A4C3.10103@balabit.hu>
References: <ifgroup.20071015.1192520046.panther@balabit.hu>	 <a6713ba13c49b7fa20073d8abf1862480c2799e0.1192457385.git.panther@balabit.hu>	 <1192531516.4480.33.camel@localhost>  <47149B04.30607@balabit.hu> <1192534002.4480.52.camel@localhost>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:47694 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753710AbXJPLrV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 07:47:21 -0400
In-Reply-To: <1192534002.4480.52.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal =EDrta:
> On Tue, 2007-16-10 at 13:05 +0200, Laszlo Attila Toth wrote:
>=20
>> That sounds great but for what whould you like to use? It may help m=
e=20
>> for the implementation.
>=20
> For example i may want to add a tc rule to a group of interfaces.
> tc BNF roughly looks like:
> tc <object> <operation> <target>
>=20
> Where targe is :=3D <dev devname>
> It may be useful to extend "target" to include alternatively a group =
of
> devices.

Ok, I see.

>=20
>> Currently it is not available since the the=20
>> net_device structure holds the group id and for this get operation a=
n=20
>> iteration (of net_devices) may be necessary...
>=20
> I understand - but i would rather do the iteration in the kernel than=
 in
> user space and save myself a gazillion netlink messages.

You are right - that's faster in the kernel and useless to move it to=20
userspace.

>=20
>> We didn't want to use multiple groups in favour of masked group ids.=
=20
>> What kind of usage needs other implementation?
>=20
> Same lazyperson use cases as above; in one case i may want to set a r=
ule
> to group =3D {eth0, eth1, eth10} and in another {eth0,eth5}. I realiz=
e
> this may be more involved something clever for an implementation (eg
> using a bitmap instead of a straight int) - so if it not a simple thi=
ng,
> just defer it to some later time.

Hm, the main problem (for me) is that it requires more then one value=20
per net device and it should be limited. But if I say it is 5 for=20
instance, anyone can say it is not enough for him.


>=20
> Ok, now that you are asking, heres another one feature request for
> you;-> It would be nice if i can set a group based on a regular
> expression of a devices name; eg "ppp*". Use case for this, off top o=
f
> my head (without looking at your syntax):
>=20
> ip set group 10 ppp*

ip link set ppp0 group 10
also if "ip link set..." works for multiple interfaces it is already=20
done. If it is not, it will affect positively all other settings :)

--=20
Attila
