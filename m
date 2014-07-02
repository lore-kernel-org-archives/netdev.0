From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Fw: CVE-2014-3532, -3533: two local DoS vulnerabilities in
 dbus-daemon
Date: Wed, 2 Jul 2014 17:48:19 +0100
Message-ID: <20140702174819.6a365ae8@rainbow.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Simon McVittie <simon.mcvittie@collabora.co.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:36986 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbaGBQsZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 12:48:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

A security issue was discovered and fixed in dbus-daemon:
CVE-2014-3532 https://bugs.freedesktop.org/show_bug.cgi?id=3D80163

I am notifying you because the issue is related to the Linux commit:

> commit 25888e30319f8896fc656fc68643e6a078263060
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Thu Nov 25 04:11:39 2010 +0000
>=20
>     af_unix: limit recursion level

and I wonder if you know any other software forwarding untrusted fds
from one unix socket to another. If so, they might be affected in a
similar way. I am not aware of any other software doing that, but if
they exist, it would be nice to tell them.

Best regards,
Alban

=3D=3D=3D=3D=3D

Begin forwarded message:

Date: Wed, 02 Jul 2014 17:04:16 +0100
=46rom: Simon McVittie <simon.mcvittie@collabora.co.uk>
To: oss-security@lists.openwall.com,  "dbus@lists.freedesktop.org"
<dbus@lists.freedesktop.org>
Cc: Alban Cr=C3=A9quy <alban.crequy@collabora.co.uk>,  Colin Walters
<walters@verbum.org>, Thiago Macieira <thiago@kde.org>
Subject: CVE-2014-3532, -3533: two local DoS vulnerabilities in
dbus-daemon


Impact: denial of service (force system services to exit)
Access required: local
Versions affected by CVE-2014-3532: dbus >=3D 1.3.0 on Linux >=3D 2.6.3=
7-rc4
Versions affected by CVE-2014-3533: dbus >=3D 1.3.0 on all Unix platfor=
ms

Alban Crequy at Collabora Ltd. discovered a bug in dbus-daemon's suppor=
t
for file descriptor passing. A malicious process could force system
services or user applications to be disconnected from the D-Bus system
bus by sending them a message containing a file descriptor, then causin=
g
that file descriptor to exceed the kernel's maximum recursion depth
(itself introduced to fix a DoS) before dbus-daemon forwards the messag=
e
to the victim process. Most services and applications exit when
disconnected from the system bus, leading to a denial of service. This
is tracked as fd.o#80163 and CVE-2014-3532.

Additionally, Alban discovered that bug fd.o#79694, a bug previously
reported by Alejandro Mart=C3=ADnez Su=C3=A1rez which was not believed =
to be a
security flaw, could be used for a similar denial of service, by causin=
g
dbus-daemon to attempt to forward invalid file descriptors to a victim
process when file descriptors become associated with the wrong message.
Its security implications are tracked as fd.o#80469 and CVE-2014-3533.

=46or the 1.8.x stable branch, these vulnerabilities are fixed in versi=
on
1.8.6. For the 1.6.x old-stable branch, these vulnerabilities are fixed
in version 1.6.22.

All earlier versions of dbus with the file descriptor passing feature
(1.3.0 and up) are believed to be vulnerable. Distributions that
backport security fixes should backport git commits
07f4c12efe3b9bd45d109bc5fbaf6d9dbf69d78e and
9ca90648fc870c24d852ce6d7ce9387a9fc9a94a, attached.

References:

[fd.o#79694] https://bugs.freedesktop.org/show_bug.cgi?id=3D79694
[fd.o#80469] https://bugs.freedesktop.org/show_bug.cgi?id=3D80469
[fd.o#80163] https://bugs.freedesktop.org/show_bug.cgi?id=3D80163

Regards,
    S
