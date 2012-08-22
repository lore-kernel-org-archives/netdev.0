From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 0/3] x86_64, sfc: 128-bit memory-mapped I/O
Date: Wed, 22 Aug 2012 02:17:55 +0100
Message-ID: <1345598275.2659.71.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<x86@kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43189 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752958Ab2HVBSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 21:18:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current Solarflare network controllers have 128-bit memory-mapped
registers which are normally accessed through a series of I/O
operations.  However, it is also possible to access them with a single
MOVAPS instruction on x86_64, and this is measurably faster as it
requires only one PCIe transaction.

This series introduces reado(), writeo() and the corresponding raw
operations on x86_64.  These could also be implemented on i386 with an
appropriate CPU selection, but it would require u128 etc. to be defined
as structure types.

The sfc driver can potentially take advantage of both 128-bit reads and
writes, but as a first step this changes only one particular write that
may be done on the data path.

Ben.

Ben Hutchings (3):
  x86_64: Define 128-bit types for kernel code only
  x86_64: Define 128-bit memory-mapped I/O operations
  sfc: Use __raw_writeo() to perform TX descriptor push where possible

 arch/x86/Kconfig.cpu                |    4 ++
 arch/x86/include/asm/io.h           |   14 +++++++
 arch/x86/include/asm/types.h        |    8 ++++
 arch/x86/lib/Makefile               |    1 +
 arch/x86/lib/oword_io.c             |   65 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/bitfield.h |    3 ++
 drivers/net/ethernet/sfc/io.h       |   18 ++++++++-
 include/linux/types.h               |   12 ++++++
 8 files changed, 123 insertions(+), 2 deletions(-)
 create mode 100644 arch/x86/lib/oword_io.c

-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
