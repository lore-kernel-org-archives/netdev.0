From: Joel Fernandes <joelaf@google.com>
Subject: [PATCH RFC v3 2/4] samples/bpf: Enable cross compiler support
Date: Sun,  3 Sep 2017 11:25:47 -0700
Message-ID: <20170903182549.30866-2-joelaf@google.com>
References: <20170903182549.30866-1-joelaf@google.com>
Cc: kernel-team@android.com, Juri Lelli <juri.lelli@arm.com>,
        Alison Chaiken <alison@she-devel.com>,
        Chenbo Feng <fengc@google.com>,
        Joel Fernandes <joelaf@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170903182549.30866-1-joelaf@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When cross compiling, bpf samples use HOSTCC for compiling the non-BPF part of
the sample, however what we really want is to use the cross compiler to build
for the cross target since that is what will load and run the BPF sample.
Detect this and compile samples correctly.

CC: Alexei Starovoitov <ast@kernel.org>
CC: Daniel Borkmann <daniel@iogearbox.net>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Joel Fernandes <joelaf@google.com>
---
 samples/bpf/Makefile | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index cf17c7932a6e..13f74b67ca44 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -177,6 +177,11 @@ HOSTLOADLIBES_syscall_tp += -lelf
 LLC ?= llc
 CLANG ?= clang
 
+# Detect that we're cross compiling and use the cross compiler
+ifdef CROSS_COMPILE
+HOSTCC = $(CROSS_COMPILE)gcc
+endif
+
 # Trick to allow make to be run from this directory
 all:
 	$(MAKE) -C ../../ $(CURDIR)/
-- 
2.14.1.581.gf28d330327-goog
