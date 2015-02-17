From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: bpf: Enable BPF JIT on ppc32
Date: Tue, 17 Feb 2015 10:04:37 +0300
Message-ID: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@lists.ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:39066 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932208AbbBQHAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 02:00:47 -0500
Received: by lbvn10 with SMTP id n10so2699368lbv.6
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 23:00:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series enables BPF JIT on ppc32. There are relatevily
few chnages in the code to make it work.

All test_bpf tests passed both on 7447a and P2041-based machines.

Changelog:
v1 - > v2: Reordered Kconfig patch in the series

Denis Kirjanov (6):
      ppc: bpf: add required compatibility macros for jit
      ppc: bpf: add reqired opcodes for ppc32
      ppc: bpf: update jit to use compatibility macros
      ppc: bpf: rename bpf_jit_64.S to bpf_jit_asm.S
      ppc: bpf: Add SKF_AD_CPU for ppc32
      ppc: Kconfig: Enable BPF JIT on ppc32

 arch/powerpc/include/asm/asm-compat.h |   4 +
 arch/powerpc/include/asm/ppc-opcode.h |   2 +
 arch/powerpc/net/Makefile             |   2 +-
 arch/powerpc/net/bpf_jit.h            |  64 +++++++++-
 arch/powerpc/net/bpf_jit_64.S         | 229 ----------------------------------
 arch/powerpc/net/bpf_jit_asm.S        | 229 ++++++++++++++++++++++++++++++++++
 arch/powerpc/net/bpf_jit_comp.c       |  46 +++----
 7 files changed, 317 insertions(+), 259 deletions(-)
