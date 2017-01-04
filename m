From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 0/6] Prepare BPF for VLAN_TAG_PRESENT cleanup
Date: Wed,  4 Jan 2017 02:18:26 +0100 (CET)
Message-ID: <cover.1483492355.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:39166 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757335AbdADCfK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 21:35:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Those patches prepare BPF ant its JITs for removal of VLAN_TAG_PRESENT.
The set depends on "Preparation for VLAN_TAG_PRESENT cleanup" patchset.

The series is supposed to be bisect-friendly and that requires temporary
insertion of #define VLAN_TAG_PRESENT in BPF code to be able to split
JIT changes per architecture.

Michał Mirosław (6):
  net/skbuff: add macros for VLAN_PRESENT bit
  net/bpf_jit: ARM: split VLAN_PRESENT bit handling from VLAN_TCI
  net/bpf_jit: MIPS: split VLAN_PRESENT bit handling from VLAN_TCI
  net/bpf_jit: PPC: split VLAN_PRESENT bit handling from VLAN_TCI
  net/bpf_jit: SPARC: split VLAN_PRESENT bit handling from VLAN_TCI
  net/bpf: split VLAN_PRESENT bit handling from VLAN_TCI

 arch/arm/net/bpf_jit_32.c       | 16 ++++++++++------
 arch/mips/net/bpf_jit.c         | 18 ++++++++++--------
 arch/powerpc/net/bpf_jit_comp.c | 17 +++++++++--------
 arch/sparc/net/bpf_jit_comp.c   | 18 ++++++++++--------
 include/linux/skbuff.h          |  6 ++++++
 net/core/filter.c               | 19 +++++++++----------
 6 files changed, 54 insertions(+), 40 deletions(-)

-- 
2.11.0
