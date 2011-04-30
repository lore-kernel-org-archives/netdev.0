From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: 2.6.39-rc5-git4: Reported regressions from 2.6.38
Date: Sat, 30 Apr 2011 13:50:04 -0700
Message-ID: <BANLkTik2L0BQ0cwOnWrgjyvxV4KMHkgaFQ@mail.gmail.com>
References: <Xp4OiTz83N.A.O0D.JVGvNB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Alex Elder <aelder-sJ/iWh9BUns@public.gmane.org>,
	xfs-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Xp4OiTz83N.A.O0D.JVGvNB@chimera>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 30, 2011 at 12:42 PM, Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote=
:
>
> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D=
34012
> Subject =A0 =A0 =A0 =A0 : 2.6.39-rc4+: oom-killer busy killing tasks
> Submitter =A0 =A0 =A0 : Christian Kujau <lists-AanptEQQ3TL9uQeqpI+JUg@public.gmane.org>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2011-04-22 1:57 (9 days old)
> Message-ID =A0 =A0 =A0: <alpine.DEB.2.01.1104211841510.18728-yMVncJ7Z0T8@public.gmane.org=
fs.org>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D130343=
744622331&w=3D2

Judging by the extended debug info in:

   http://nerdbynature.de/bits/2.6.39-rc4/oom/
   (The -9 files are the current ones)

that thing shows a _lot_ of xfs inodes:

  xfs_inode         479187 479187   1120   14    4 : tunables    0
0    0 : slabdata  34329  34329      0

even though there aren't that many dentries (each inode should have at
least one dentry associated with it under normal circumstances):

  dentry             97896  97900    160   25    1 : tunables    0
0    0 : slabdata   3916   3916      0

and then later when the system gets low on memory, the dentries shrink:

  dentry              1017   3525    160   25    1 : tunables    0
0    0 : slabdata    141    141      0

but the XFS inodes do not:

  xfs_inode         557579 557579   1120   14    4 : tunables    0
0    0 : slabdata  41492  41492      0

so I suspect it's some kind of XFS inode leak.

                      Linus
