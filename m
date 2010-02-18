From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the kvm tree
Date: Thu, 18 Feb 2010 13:15:39 +1100
Message-ID: <20100218131539.0f10c2e7.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Kiszka <jan.kiszka@web.de>, Avi Kivity <avi@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
Documentation/feature-removal-schedule.txt between commit
f5c9db332c54af513e5bee5cd84f5aadb8d21f55 ("KVM: Plan obsolescence of
kernel allocated slots, paravirt mmu") from the kvm tree and commit
79e95f4717767e9ddc4dbec5d778f0c9970eed34 ("CAPI: Schedule capifs for
removal") from the net tree.

Just overlapping additions. I fixed it up (see below) and can carry the
fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc Documentation/feature-removal-schedule.txt
index 47a6554,721a2aa..0000000
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@@ -545,30 -524,10 +524,40 @@@ Who:	Hans de Goede <hdegoede@redhat.com
  
  ----------------------------
  
 +What:	KVM memory aliases support
 +When:	July 2010
 +Why:	Memory aliasing support is used for speeding up guest vga access
 +	through the vga windows.
 +
 +	Modern userspace no longer uses this feature, so it's just bitrotted
 +	code and can be removed with no impact.
 +Who:	Avi Kivity <avi@redhat.com>
 +
 +----------------------------
 +
 +What:	KVM kernel-allocated memory slots
 +When:	July 2010
 +Why:	Since 2.6.25, kvm supports user-allocated memory slots, which are
 +	much more flexible than kernel-allocated slots.  All current userspace
 +	supports the newer interface and this code can be removed with no
 +	impact.
 +Who:	Avi Kivity <avi@redhat.com>
 +
 +----------------------------
 +
 +What:	KVM paravirt mmu host support
 +When:	January 2011
 +Why:	The paravirt mmu host support is slower than non-paravirt mmu, both
 +	on newer and older hardware.  It is already not exposed to the guest,
 +	and kept only for live migration purposes.
 +Who:	Avi Kivity <avi@redhat.com>
++
++----------------------------
++
+ What:	capifs
+ When:	February 2011
+ Files:	drivers/isdn/capi/capifs.*
+ Why:	udev fully replaces this special file system that only contains CAPI
+ 	NCCI TTY device nodes. User space (pppdcapiplugin) works without
+ 	noticing the difference.
+ Who:	Jan Kiszka <jan.kiszka@web.de>
