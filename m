From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 00/12] nfp: bpf: support direct packet access
Date: Thu, 12 Oct 2017 10:34:06 -0700
Message-ID: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:43241 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752246AbdJLRet (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:34:49 -0400
Received: by mail-pf0-f181.google.com with SMTP id a8so5395068pfc.0
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:34:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

The core of this series is direct packet access support.  With a
small change to the verifier, the offloaded code can now make
use of DPA.  We need to be careful to use kernel (after initial
translation) offsets in our JIT.  Direct packet access also brings
us to the problem of eBPF endianness.  After considering the 
changes necessary we decided to not support translation on both
BE and LE hosts, for now.

This series contains two fixes - one for compare instructions and
one for ineffective jne optimization.  I chose to include fixes
in this set because the code in -net works only with unreleased
PoC FW (ABI version 1) and therefore nobody outside of Netronome
can exercise it anyway.


Jakub Kicinski (12):
  bpf: verifier: set reg_type on context accesses in second pass
  nfp: bpf: reorder arguments to emit_ld_field_any()
  nfp: bpf: add missing return in jne_imm optimization
  nfp: bpf: fix compare instructions
  nfp: bpf: add mov helper
  nfp: bpf: implement byte swap instruction
  nfp: bpf: support BPF offload only on little endian
  nfp: bpf: fix context accesses
  nfp: bpf: separate I/O from checks for legacy data load
  nfp: bpf: add support for direct packet access - read
  nfp: bpf: direct packet access - write
  nfp: bpf: support direct packet access in TC

 drivers/net/ethernet/netronome/nfp/bpf/jit.c      | 402 ++++++++++++++++++----
 drivers/net/ethernet/netronome/nfp/bpf/main.c     |   2 +
 drivers/net/ethernet/netronome/nfp/bpf/main.h     |   3 +
 drivers/net/ethernet/netronome/nfp/bpf/verifier.c |  21 +-
 drivers/net/ethernet/netronome/nfp/nfp_asm.c      |   5 +-
 drivers/net/ethernet/netronome/nfp/nfp_asm.h      |   6 +-
 kernel/bpf/verifier.c                             |  43 ++-
 7 files changed, 393 insertions(+), 89 deletions(-)

-- 
2.14.1
