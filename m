From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 0/9] powerpc32: set of optimisation of network checksum functions
Date: Tue, 22 Sep 2015 16:34:17 +0200 (CEST)
Message-ID: <cover.1442876807.git.christophe.leroy@c-s.fr>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, scottwood@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2.236.17.93.rev.sfr.net ([93.17.236.2]:55458 "EHLO
	mailhub1.si.c-s.fr" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756816AbbIVOeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 10:34:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch serie gather patches related to checksum functions on powerpc.
Some of those patches have already been submitted individually.

Christophe Leroy (9):
  powerpc: unexport csum_tcpudp_magic
  powerpc: mark xer clobbered in csum_add()
  powerpc32: checksum_wrappers_64 becomes checksum_wrappers
  powerpc: inline ip_fast_csum()
  powerpc32: rewrite csum_partial_copy_generic() based on
    copy_tofrom_user()
  powerpc32: optimise a few instructions in csum_partial()
  powerpc32: optimise csum_partial() loop
  powerpc: simplify csum_add(a, b) in case a or b is constant 0
  powerpc: optimise csum_partial() call when len is constant

 arch/powerpc/include/asm/checksum.h                | 143 +++++---
 arch/powerpc/lib/Makefile                          |   3 +-
 arch/powerpc/lib/checksum_32.S                     | 398 +++++++++++++--------
 arch/powerpc/lib/checksum_64.S                     |  31 +-
 ...{checksum_wrappers_64.c => checksum_wrappers.c} |   0
 arch/powerpc/lib/ppc_ksyms.c                       |   4 +-
 6 files changed, 350 insertions(+), 229 deletions(-)
 rename arch/powerpc/lib/{checksum_wrappers_64.c => checksum_wrappers.c} (100%)

-- 
2.1.0
