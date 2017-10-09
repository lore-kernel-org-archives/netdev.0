From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 00/15] nfp: bpf ABIv2 and multi port
Date: Sun,  8 Oct 2017 21:04:02 -0700
Message-ID: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:55754 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751530AbdJIEFr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:05:47 -0400
Received: by mail-pf0-f182.google.com with SMTP id 17so4192258pfn.12
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:05:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series migrates our eBPF offload from old PoC firmware to 
a redesigned, faster and more feature rich FW.  Marking support
is dropped for now.  We have to teach the JIT about encoding
local memory accesses (one of NFP memory types).  There is also
code to populate the ECC of instructions (PoC had ECC protection
on instruction store disabled).  There is also a minor ld_field
fix and all 64 bit shifts can now be encoded.


Jakub Kicinski (15):
  nfp: output control messages to trace_devlink_hwmsg()
  nfp: bpf: lift the single-port limitation
  nfp: bpf: use the power of sparse to check we encode registers right
  nfp: bpf: move software reg helpers and cmd table out of translator
  nfp: bpf: encode all 64bit shifts
  nfp: bpf: remove register rename
  nfp: bpf: remove packet marking support
  nfp: add more white space to the instruction defines
  nfp: bpf: encode LMEM accesses
  nfp: bpf: encode extended LM pointer operands
  nfp: bpf: move to datapath ABI version 2
  nfp: bpf: calculate code store ECC
  nfp: bpf: pad code with valid nops
  nfp: bpf: byte swap the instructions
  nfp: bpf: pass dst register to ld_field instruction

 drivers/net/ethernet/netronome/nfp/Makefile       |   1 +
 drivers/net/ethernet/netronome/nfp/bpf/jit.c      | 403 ++++++++--------------
 drivers/net/ethernet/netronome/nfp/bpf/main.c     |   8 -
 drivers/net/ethernet/netronome/nfp/bpf/main.h     |  49 +--
 drivers/net/ethernet/netronome/nfp/nfp_app.h      |   8 +
 drivers/net/ethernet/netronome/nfp/nfp_asm.c      | 254 ++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_asm.h      | 293 +++++++++++-----
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h |   2 +-
 8 files changed, 640 insertions(+), 378 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_asm.c

-- 
2.14.1
