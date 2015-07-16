From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH 0/6] BPF JIT fixes and features for ARM
Date: Thu, 16 Jul 2015 18:46:29 +0200
Message-ID: <1437065195-10887-1-git-send-email-nschichan@freebox.fr>
Cc: Russell King <linux@arm.linux.org.uk>,
	Alexei Starovoitov <ast@plumgrid.com>
To: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Mircea Gherzan <mgherzan@gmail.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This serie fixes issues with the ARM BPF JIT and adds support for more
instructions to the ARM BPF JIT.

The first three patches are fixing bugs in the ARM JIT and should
probably find their way to a stable kernel.

The last three patches add support to the ARM JIT for more BPF
instructions, namely skb netdevice type retrieval, skb payload offset
retrieval, and skb packet type retrieval.

With the first three patches, all 60 test_bpf tests in Linux 4.1 release
are now passing OK (was 54 out of 60 before).

The last three patches allow 35 tests to use the JIT instead of 29
before.

Like previous ARM JIT patches this should go via the net tree.

Regards,

Nicolas Schichan (6):
  ARM: net: fix condition for load_order > 0 when translating load
    instructions.
  ARM: net: handle negative offsets in BPF JIT.
  ARM: net: fix vlan access instructions in ARM JIT.
  ARM: net: add support for BPF_ANC | SKF_AD_PKTTYPE in ARM JIT.
  ARM: net: add support for BPF_ANC | SKF_AD_PAY_OFFSET in ARM JIT.
  ARM: net: add support for BPF_ANC | SKF_AD_HATYPE in ARM JIT.

 arch/arm/net/bpf_jit_32.c | 98 +++++++++++++++++++++++++++++++++++++++--------
 arch/arm/net/bpf_jit_32.h |  3 ++
 2 files changed, 86 insertions(+), 15 deletions(-)

-- 
1.9.1
