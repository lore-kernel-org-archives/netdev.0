From: =?UTF-8?B?SMOla29uIEzDuHZkYWw=?= <hlovdal@gmail.com>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sat, 31 May 2008 19:58:21 +0200
Message-ID: <484191BD.8000904@gmail.com>
References: <20080526115628.GA31316@elte.hu> <1211966834.12349.62.camel@twins> <a01a16b50805310725x4f1c375ep2d091bb044ac0787@mail.gmail.com> <Pine.LNX.4.64.0805311839540.2657@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: =?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:37662 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096AbYEaR6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 13:58:39 -0400
Received: by ug-out-1314.google.com with SMTP id h2so108116ugf.16
        for <netdev@vger.kernel.org>; Sat, 31 May 2008 10:58:35 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0805311839540.2657@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=C3=A4rvinen wrote:
> Hmm, are the other end's processes still there? ...I'd be interested =
to=20
> know what they're doing at the moment...

> I meant that end where you see this '-'. I suppose it's easy for you =
to
> figure out which process is the right one, something that wouldn't be=
 so
> easy with the Ingo's test case which forks/exits numerous times.

> Died? Do you mean that they don't exist all at the other end anymore?

The ssh connection used for copying (using the command <ssh old_pc "cd
/directory; tar cvf - *" | pv | tar xvf ->) died in the following way:
   ...
   Read from remote host old_pc: Connection timed out
   51.4GB 4:26:19 [3.29MB/s] [<=3D>                                   ]
   tar: Unexpected EOF in archive
   tar: Unexpected EOF in archive
   tar: Error is not recoverable: exiting now

and there are currently no traces of those ssh processes any longer on
the new PC, only these two active ssh interactive connections are prese=
nt:

new_pc>ps -elf | sed -n '1p;/ssh/p'
=46 S UID        PID  PPID  C PRI  NI ADDR SZ WCHAN  STIME TTY         =
 TIME CMD
0 S hlovdal   1310  1195  0  80   0 - 14139 select 09:28 pts/14   00:00=
:00 ssh old_pc
5 S root      2477     1  0  80   0 - 15203 -      May26 ?        00:00=
:00 /usr/sbin/sshd
1 S hlovdal   2727  2701  0  80   0 - 12466 select May26 ?        00:00=
:00 /usr/bin/ssh-agent /bin/sh -c exec -l /bin/bash -c "/usr/bin/startk=
de"
0 S hlovdal  26436 19976  0  80   0 - 20375 pipe_w 19:43 pts/9    00:00=
:00 sed -n 1p;/ssh/p
0 S hlovdal  30065 18970  0  80   0 - 14174 select May28 pts/6    00:00=
:00 ssh old_pc
new_pc>

On the old PC there are three corresponding zombies:

old_pc>ps -elf | sed -n '1p;/ssh/p'
=46 S UID        PID  PPID  C PRI  NI ADDR SZ WCHAN  STIME TTY         =
 TIME CMD
5 S root      4402     1  0  80   0 -  1600 -      May25 ?        00:00=
:02 /usr/sbin/sshd
1 S root      5418     1  0  80   0 -  1347 -      May25 ?        00:00=
:00 ssh-agent
1 S hlovdal   5752     1  0  80   0 -  1347 -      May25 ?        00:00=
:00 ssh-agent
4 S root      6824  4402  0  80   0 -  2315 -      09:28 ?        00:00=
:00 sshd: hlovdal [priv]
5 S hlovdal   6828  6824  0  80   0 -  2355 -      09:28 ?        00:00=
:01 sshd: hlovdal@pts/8
0 S hlovdal  17186 25557  0  80   0 -  1191 -      19:45 pts/0    00:00=
:00 sed -n 1p;/ssh/p
4 D root     24444  4402  0  80   0 -     0 -      May27 ?        00:00=
:00 [sshd]
5 Z hlovdal  24448 24444  0  80   0 -     0 -      May27 ?        00:58=
:33 [sshd] <defunct>
4 S root     25552  4402  0  80   0 -  2315 -      May28 ?        00:00=
:00 sshd: hlovdal [priv]
5 S hlovdal  25556 25552  0  80   0 -  2383 -      May28 ?        00:00=
:01 sshd: hlovdal@pts/0
1 S hlovdal  28504 28328  0  80   0 -  1347 -      May28 ?        00:00=
:01 /usr/bin/ssh-agent /usr/bin/dbus-launch --exit-with-session /usr/bi=
n/startkde
4 D root     31338  4402  0  80   0 -     0 -      May27 ?        00:00=
:00 [sshd]
5 Z hlovdal  31342 31338  0  80   0 -     0 -      May27 ?        00:07=
:55 [sshd] <defunct>
4 D root     31564  4402  0  80   0 -     0 -      May27 ?        00:00=
:00 [sshd]
5 Z hlovdal  31568 31564  0  80   0 -     0 -      May27 ?        00:43=
:53 [sshd] <defunct>
old_pc>


>> I can post output from /proc/net/tcp
>=20
> For both ends that would be great.

111111AC is the old PC.
480111AC is the new PC.

new_pc>sed -n '1p; /:0016/p' /proc/net/tcp
sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrns=
mt   uid  timeout inode
 3: 00000000:0016 00000000:0000 0A 00000000:00000000 00:00000000 000000=
00     0        0 8850 1 ffff81022ddd2680 3000 0 0 2 -1
 7: 480111AC:AB31 111111AC:0016 01 00000000:00000000 02:000A2A2B 000000=
00   500        0 138582 2 ffff81022d9d7380 202 40 22 3 -1
 8: 480111AC:CDBB 111111AC:0016 01 00000000:00000000 02:0001BBAD 000000=
00   500        0 723741 2 ffff81017560c000 202 40 18 3 -1
new_pc>


old_pc>sed -n '1p; /:0016/p' /proc/net/tcp
sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrns=
mt   uid  timeout inode
12: 00000000:0016 00000000:0000 0A 00000000:00000000 00:00000000 000000=
00     0        0 7627 1 f384b080 3000 0 0 2 -1
17: 111111AC:0016 480111AC:CDBB 01 00000000:00000000 02:0001AA7B 000000=
00     0        0 1110320 2 f02e6580 201 53 7 3 -1
20: 111111AC:0016 480111AC:AB31 01 00000000:00000000 02:000A18F1 000000=
00     0        0 583506 4 f71a8080 201 40 29 3 -1
21: 111111AC:0016 480111AC:E4E9 01 00000B50:00000000 01:7D1F8746 000000=
00     0        0 398713 5 f71a8580 205 40 1 36 -1
23: 111111AC:0016 480111AC:D359 01 000010F8:00000000 01:7D19A035 000000=
00     0        0 396426 5 f71a8a80 202 42 1 144 -1
25: 111111AC:0016 480111AC:8565 01 00000B50:00000000 01:7CEBA7D1 000000=
00     0        0 349113 5 eeeaf580 204 40 1 26 -1
old_pc>


BR H=C3=A5kon L=C3=B8vdal


