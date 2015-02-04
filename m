From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v3 2/3] genetlink: disallow subscribing to unknown mcast groups
Date: Wed, 04 Feb 2015 17:15:47 +0100
Message-ID: <874mr1ps98.fsf@nemi.mork.no>
References: <1421404634-8973-1-git-send-email-johannes@sipsolutions.net>
	<1421404634-8973-2-git-send-email-johannes@sipsolutions.net>
	<87egq5uc07.fsf@nemi.mork.no> <87d25pit90.fsf@nemi.mork.no>
	<1423064608.4741.6.camel@sipsolutions.net>
	<874mr1isch.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jeff Layton <jeff.layton@primarydata.com>,
	Sedat Dilek <sedat.dilek@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53486 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966276AbbBDQPz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 11:15:55 -0500
In-Reply-To: <874mr1isch.fsf@nemi.mork.no> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of "Wed, 04
	Feb 2015 16:55:42 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:

> So I am pretty sure Pablo's patch fixes the problem.

Confirmed now.

Running acpid on v3.19-rc7 + commit 8b7c36d810c6 ("netlink: fix
wrong subscription bitmask to group mapping in") works fine:

nemi:/tmp# strace -s 128 -e trace=3Dsocket,bind,sendmsg,recvmsg -f acpi=
d -l -d
socket(PF_LOCAL, SOCK_DGRAM|SOCK_CLOEXEC, 0) =3D 3
Deprecated /proc/acpi/event was not found.  Trying netlink and the inpu=
t layer...
input layer /dev/input/event0 (AT Translated Set 2 keyboard) opened suc=
cessfully, fd 4
input layer /dev/input/event1 (Lid Switch) opened successfully, fd 5
input layer /dev/input/event10 (HDA Intel Headphone) opened successfull=
y, fd 6
input layer /dev/input/event2 (Sleep Button) opened successfully, fd 7
input layer /dev/input/event3 (Power Button) opened successfully, fd 8
input layer /dev/input/event4 (Video Bus) opened successfully, fd 9
input layer /dev/input/event5 (ThinkPad Extra Buttons) opened successfu=
lly, fd 10
input layer /dev/input/event7 (HDA Intel Mic) opened successfully, fd 1=
1
input layer /dev/input/event8 (HDA Intel Dock Mic) opened successfully,=
 fd 12
input layer /dev/input/event9 (HDA Intel Dock Headphone) opened success=
fully, fd 13
inotify fd: 14
inotify wd: 1
socket(PF_NETLINK, SOCK_RAW|SOCK_CLOEXEC, NETLINK_GENERIC) =3D 15
bind(15, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000000}, 12) =3D =
0
sendmsg(15, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0, groups=3D=
00000000}, msg_iov(1)=3D[{"$\0\0\0\20\0\5\0oD\322T\0\0\0\0\3\0\0\0\17\0=
\2\0acpi_event\0\0", 36}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 3=
6
recvmsg(15, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0, groups=3D=
00000000}, msg_iov(1)=3D[{"h\0\0\0\20\0\0\0oD\322T@\20\0\0\1\2\0\0\17\0=
\2\0acpi_event\0\0\6\0\1\0\23\0\0\0\10\0\3\0\1\0\0\0\10\0\4\0\0\0\0\0\1=
0\0\5\0\1\0\0\0$\0\7\0 \0\1\0\10\0\2\0\2\0\0\0\22\0\1\0acpi_mc_group\0\=
0\0", 16384}], msg_controllen=3D0, msg_flags=3DMSG_CMSG_CLOEXEC}, MSG_C=
MSG_CLOEXEC) =3D 104
socket(PF_NETLINK, SOCK_RAW|SOCK_CLOEXEC, NETLINK_GENERIC) =3D 15
bind(15, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000002}, 12) =3D =
0
netlink opened successfully
socket(PF_LOCAL, SOCK_STREAM|SOCK_CLOEXEC|SOCK_NONBLOCK, 0) =3D 16
bind(16, {sa_family=3DAF_LOCAL, sun_path=3D"/var/run/acpid.socket"}, 11=
0) =3D 0
acpid: starting up with netlink and the input layer
parsing conf file /etc/acpi/events/powerbtn-acpi-support
acpid: skipping non-file /etc/acpi/events/CVS
parsing conf file /etc/acpi/events/any
parsing conf file /etc/acpi/events/generic-hibernatebtn
parsing conf file /etc/acpi/events/low_battery
parsing conf file /etc/acpi/events/lidbtn
parsing conf file /etc/acpi/events/sleepbtn
acpid: 6 rules loaded
acpid: waiting for events: event logging is on



And the acpi events are of course received as expected.  Thanks again
for making the kernel more robust.



Bj=C3=B8rn
