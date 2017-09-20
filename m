From: Joel Fernandes <joelaf@google.com>
Subject: [PATCH v4 2/4] samples/bpf: Enable cross compiler support
Date: Wed, 20 Sep 2017 09:11:57 -0700
Message-ID: <20170920161159.25747-2-joelaf@google.com>
References: <20170920161159.25747-1-joelaf@google.com>
Cc: netdev@vger.kernel.org, alison@she-devel.com, juri.lelli@arm.com,
        fengc@google.com, daniel@iogearbox.net, davem@davemloft.net,
        ast@kernel.org, kernel-team@android.com,
        Joel Fernandes <joelaf@google.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920161159.25747-1-joelaf@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When cross compiling, bpf samples use HOSTCC for compiling the non-BPF part of
the sample, however what we really want is to use the cross compiler to build
for the cross target since that is what will load and run the BPF sample.
Detect this and compile samples correctly.

Acked-by: Alexei Starovoitov <ast@kernel.org>
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
2.14.1.821.g8fa685d3b7-goog
