From: Christoph Hellwig <hch@infradead.org>
Subject: [bernie@develer.com: Kernel 2.6 size increase]
Date: Wed, 23 Jul 2003 19:53:55 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723195355.A27597@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I think this is not only of interest fir the uClinux folks..

----- Forwarded message from Bernardo Innocenti <bernie@develer.com> -----

Date:	Wed, 23 Jul 2003 20:46:46 +0200
From:	Bernardo Innocenti <bernie@develer.com>
Subject: Kernel 2.6 size increase
To:	uClinux development list <uclinux-dev@uclinux.org>
Cc:	linux-kernel@vger.kernel.org

Hello,

code bloat can be very harmful on embedded targets, but it's
generally inconvenient for any platform. I've measured the
code increase between 2.4.21 and 2.6.0-test1 on a small
kernel configuration for ColdFire:

   text    data     bss     dec     hex filename
 640564   39152  134260  813976   c6b98 linux-2.4.x/linux
 845924   51204   78896  976024   ee498 linux-2.5.x/vmlinux

I could provide the exact .config file for both kernels to
anybody interested. They are almost the same: no filesystems
except JFFS2, IPv4 and a bunch of small drivers. I have no
SMP, security, futexes, modules and anything else not
strictly needed to execute processes.

I've made a linker map file and compared the size of single
subsystems. These are the the major contributors to the
size increase:

  kernel/   +27KB
  mm/       +14KB
  fs/       +47KB
  drivers/  +35KB
  net/      +64KB

I've digged into net/ with nm -S --size-sort. It seems that
the major increase is caused by net/xfrm/. Could this module
be made optional?

In fs/, almost all modules have got 30-40% bigger, therefore
bloat is probably caused by inlines and macros getting more
complex.

Block drivers and MTD have generally become smaller. Character
devices are responsable for most of the size increase in drivers/.

-- 
  // Bernardo Innocenti - Develer S.r.l., R&D dept.
\X/  http://www.develer.com/

Please don't send Word attachments - http://www.gnu.org/philosophy/no-word-attachments.html


-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

----- End forwarded message -----
