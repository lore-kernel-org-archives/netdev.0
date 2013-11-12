From: Dilip Daya <dilip.daya@hp.com>
Subject: Re: iproute2: potential upgrade regression with 58a3e827
Date: Mon, 11 Nov 2013 19:36:52 -0500
Message-ID: <1384216612.2758.30.camel@dilip-laptop>
References: <527D2768.1030403@canonical.com> <527E6A32.5020808@hp.com>
	 <52814B88.1050708@canonical.com> <1384205890.2758.28.camel@dilip-laptop>
	 <871u2mblzk.fsf@xmission.com>
Reply-To: dilip.daya@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris J Arges <chris.j.arges@canonical.com>,
	Brian Haley <brian.haley@hp.com>, shemminger@osdl.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:44090 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807Ab3KLAg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 19:36:58 -0500
In-Reply-To: <871u2mblzk.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Mon, 2013-11-11 at 14:40 -0800, Eric W. Biederman wrote:
> Dilip Daya <dilip.daya@hp.com> writes:
>=20
> > Hi Chris,
> >
> > On Mon, 2013-11-11 at 15:26 -0600, Chris J Arges wrote:
> >
> >> Good suggestion,
> >> So I'll use a more simple example now:
> >>=20
> >> 1)
> >> ip netns add first
> >> ip netns exec first bash
> >>=20
> >> 2)
> >> ip netns add second
> >> ip netns exec second bash
> >>=20
> >> 3)
> >> ip netns exec first bash
> >>=20
> >> If we do not upgrade the package, after we execute (2) we have:
> >> # ls -l /var/run/netns
> >> total 0
> >> -r-------- 1 root root 0 Nov 11 20:38 first
> >> -r-------- 1 root root 0 Nov 11 20:38 second
> >>=20
> >> If we upgrade after (1), then run (2) we have:
> >> # ls -l /var/run/netns
> >> total 0
> >> ---------- 1 root root 0 Nov 11 20:56 first
> >> -r-------- 1 root root 0 Nov 11 20:57 second
> >>=20
> >> So looks like netns add is doing something different from 58a3e827=
 and on.
>=20
> I will just add that it is worth looking at /proc/mounts as well.
>=20
> Although I have to admit that the difference in permissions is odd.


=3D> kernel v3.2.51 with iproute2-ss130903


Terminal #1--Add first netns
# ip netns add first


Terminal #1:
# tree --inodes /var/run/netns ; echo "=3D=3D=3D=3D=3D" ; ls -li /var/r=
un/netns ; echo "=3D=3D=3D=3D=3D"; cat /proc/self/mounts | grep first ;=
 echo "=3D=3D=3D=3D=3D" ; cat /proc/self/mountinfo | grep -e first
/var/run/netns
=E2=94=94=E2=94=80=E2=94=80 [   5204]  first

0 directories, 1 file
=3D=3D=3D=3D=3D
total 0
5204 -r-------- 1 root root 0 Nov 11 17:17 first
=3D=3D=3D=3D=3D
none /var/run/netns/first proc rw,nosuid,nodev,noexec,relatime 0 0
=3D=3D=3D=3D=3D
23 22 0:3 /1935/ns/net /var/run/netns/first rw,nosuid,nodev,noexec,rela=
time shared:2 - proc none rw


Terminal #1:
# ip netns exec first /bin/bash


Terminal #1:
# tree --inodes /var/run/netns ; echo "=3D=3D=3D=3D=3D" ; ls -li /var/r=
un/netns ; echo "=3D=3D=3D=3D=3D"; cat /proc/self/mounts | grep first ;=
 echo "=3D=3D=3D=3D=3D" ; cat /proc/self/mountinfo | grep -e first
/var/run/netns
=E2=94=94=E2=94=80=E2=94=80 [   5204]  first

0 directories, 1 file
=3D=3D=3D=3D=3D
total 0
5204 -r-------- 1 root root 0 Nov 11 17:17 first
=3D=3D=3D=3D=3D
none /var/run/netns/first proc rw,nosuid,nodev,noexec,relatime 0 0
first /sys sysfs rw,relatime 0 0
=3D=3D=3D=3D=3D
33 32 0:3 /1935/ns/net /var/run/netns/first rw,nosuid,nodev,noexec,rela=
time master:2 - proc none rw
29 25 0:17 / /sys rw,relatime - sysfs first rw


Terminal #1:
# ip netns add second


Terminal #1:
# tree --inodes /var/run/netns ; echo "=3D=3D=3D=3D=3D" ; ls -li /var/r=
un/netns ; echo "=3D=3D=3D=3D=3D"; cat /proc/self/mounts | grep first ;=
 echo "=3D=3D=3D=3D=3D" ; cat /proc/self/mountinfo | grep -e first -e s=
econd
/var/run/netns
=E2=94=9C=E2=94=80=E2=94=80 [   5204]  first
=E2=94=94=E2=94=80=E2=94=80 [   5236]  second

0 directories, 2 files
=3D=3D=3D=3D=3D
total 0
5204 -r-------- 1 root root 0 Nov 11 17:17 first
5236 -r-------- 1 root root 0 Nov 11 17:21 second   <<< observe this in=
ode # and permissions
=3D=3D=3D=3D=3D
none /var/run/netns/first proc rw,nosuid,nodev,noexec,relatime 0 0
first /sys sysfs rw,relatime 0 0
=3D=3D=3D=3D=3D
33 32 0:3 /1935/ns/net /var/run/netns/first rw,nosuid,nodev,noexec,rela=
time shared:4 master:2 - proc none rw
29 25 0:17 / /sys rw,relatime - sysfs first rw
34 32 0:3 /1955/ns/net /var/run/netns/second rw,nosuid,nodev,noexec,rel=
atime shared:5 - proc none rw



Terminal #2--in main (not in netns):
# tree --inodes /var/run/netns ; echo "=3D=3D=3D=3D=3D" ; ls -li /var/r=
un/netns ; echo "=3D=3D=3D=3D=3D"; cat /proc/self/mounts | grep first ;=
 echo "=3D=3D=3D=3D=3D" ; cat /proc/self/mountinfo | grep -e first -e s=
econd
/var/run/netns
=E2=94=9C=E2=94=80=E2=94=80 [   5204]  first
=E2=94=94=E2=94=80=E2=94=80 [  51492]  second   <<< inode is different

0 directories, 2 files
=3D=3D=3D=3D=3D
total 0
 5204 -r-------- 1 root root 0 Nov 11 17:17 first
51492 ---------- 1 root root 0 Nov 11 17:21 second   << inode different=
 with NULL permissions
=3D=3D=3D=3D=3D
none /var/run/netns/first proc rw,nosuid,nodev,noexec,relatime 0 0
=3D=3D=3D=3D=3D
23 22 0:3 /1935/ns/net /var/run/netns/first rw,nosuid,nodev,noexec,rela=
time shared:2 - proc none rw

=3D> When in main (not in netns) "second" netns is not viewable.


Terminal #2--Enter first:
# ip netns exec first bash


Terminal #2:
# tree --inodes /var/run/netns ; echo "=3D=3D=3D=3D=3D" ; ls -li /var/r=
un/netns ; echo "=3D=3D=3D=3D=3D"; cat /proc/self/mounts | grep first ;=
 echo "=3D=3D=3D=3D=3D" ; cat /proc/self/mountinfo | grep -e first -e s=
econd
/var/run/netns
=E2=94=9C=E2=94=80=E2=94=80 [   5204]  first
=E2=94=94=E2=94=80=E2=94=80 [  51492]  second   <<< inode different the=
n when created from first in Terminal #1 above

0 directories, 2 files
=3D=3D=3D=3D=3D
total 0
 5204 -r-------- 1 root root 0 Nov 11 17:17 first
51492 ---------- 1 root root 0 Nov 11 17:21 second   <<< inode with NUL=
L permissions
=3D=3D=3D=3D=3D
none /var/run/netns/first proc rw,nosuid,nodev,noexec,relatime 0 0
first /sys sysfs rw,relatime 0 0
=3D=3D=3D=3D=3D
44 43 0:3 /1935/ns/net /var/run/netns/first rw,nosuid,nodev,noexec,rela=
time master:2 - proc none rw
40 36 0:17 / /sys rw,relatime - sysfs first rw

=3D> mounts and mountinfo does not show "second"


Terminal #2:
# ip netns exec second /bin/bash
seting the network namespace "second" failed: Invalid argument

=3D> "second" netns is now rendered unusable from "first" netns and fro=
m main.



Thanks,
-DilipD.



>=20
> Eric

--=20
-DilipD.
