From: Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org>
Subject: Re: 3.2-rc6+: Reported regressions from 3.0 and 3.1
Date: Wed, 21 Dec 2011 07:45:37 +0100
Message-ID: <20111221064537.GD1629@x4>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera>
 <201112210039.14100.linux-pm-bounces@lists.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM list <linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201112210039.14100.linux-pm-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2011.12.21 at 00:54 +0100, Rafael J. Wysocki wrote:
> Subject    : WARNING: at fs/sysfs/sysfs.h:195 (during boot)
> Submitter  : Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org>
> Date       : 2011-11-13 19:24
> Message-ID : 20111113192417.GA1659-tLCgZGx+iJ+kxVt8IV0GqQ-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org
> References : http://marc.info/?l=linux-kernel&m=132121231921932&w=2
> 
> Subject    : WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
> Submitter  : Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org>
> Date       : 2011-11-18 7:25
> Message-ID : 20111118072519.GA1615-tLCgZGx+iJ+kxVt8IV0GqQ-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org
> References : http://marc.info/?l=linux-kernel&m=132160119031794&w=2

Both entries were caused by the same Radeon kexec writeback bug. This issue
will hopefully be fixed in the next release.

> Subject    : Impossible high cpu-time values for migration threads
> Submitter  : Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org>
> Date       : 2011-11-17 22:17
> Message-ID : 20111117221731.GA9229-tLCgZGx+iJ+kxVt8IV0GqQ-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org
> References : http://marc.info/?l=linux-kernel&m=132156832124314&w=2

This is a cosmetic issue, but I'm still seeing this after bursts of high
CPU usage:

 % ps afx -F
UID        PID  PPID  C    SZ   RSS PSR STIME TTY      STAT   TIME CMD
root         2     0  0     0     0   1 Dec20 ?        S      0:00 [kthreadd]
root         3     2  0     0     0   0 Dec20 ?        S      0:01  \_ [ksoftirqd/0]
root         6     2  0     0     0   0 Dec20 ?        S      0:00  \_ [migration/0]
root         7     2  0     0     0   1 Dec20 ?        S      0:00  \_ [migration/1]
root         8     2  0     0     0   1 Dec20 ?        S      0:05  \_ [kworker/1:0]
root         9     2  0     0     0   1 Dec20 ?        S      0:01  \_ [ksoftirqd/1]
root        11     2  0     0     0   2 Dec20 ?        S      0:00  \_ [migration/2]
root        13     2  0     0     0   2 Dec20 ?        S      0:01  \_ [ksoftirqd/2]
root        14     2 22     0     0   3 Dec20 ?        S    192:21  \_ [migration/3]
root        16     2  0     0     0   3 Dec20 ?        S      0:01  \_ [ksoftirqd/3]
root        17     2  0     0     0   2 Dec20 ?        S<     0:00  \_ [khelper]
...

-- 
Markus
