From: Joel Fernandes <joelaf@google.com>
Subject: [PATCH RFC v2 2/5] samples/bpf: Enable cross compiler support
Date: Mon,  7 Aug 2017 06:05:59 -0700
Message-ID: <20170807130602.31785-3-joelaf@google.com>
References: <20170807130602.31785-1-joelaf@google.com>
Cc: Chenbo Feng <fengc@google.com>,
        Alison Chaiken <alison@she-devel.com>, Juri.Lelli@arm.com,
        Joel Fernandes <joelaf@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        netdev@vger.kernel.org (open list:BPF (Safe dynamic programs and tools))
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807130602.31785-1-joelaf@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When cross compiling, bpf samples use HOSTCC, however what we really want is to
use the cross compiler to build for the cross target since that is what will
help run the BPF target code.  Detect this and also set -static as LDFLAGS
since often times we don't have control over what C library the cross target is
running and its not smart to rely on it.

Signed-off-by: Joel Fernandes <joelaf@google.com>
---
 samples/bpf/Makefile | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 6c7468eb3684..e5642c8c144d 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -152,6 +152,12 @@ HOSTLOADLIBES_test_map_in_map += -lelf
 LLC ?= llc
 CLANG ?= clang
 
+# Detect that we're cross compiling and use the right compilers and flags
+ifdef CROSS_COMPILE
+HOSTCC = $(CROSS_COMPILE)gcc
+HOSTLDFLAGS += -static
+endif
+
 # Trick to allow make to be run from this directory
 all:
 	$(MAKE) -C ../../ $(CURDIR)/
-- 
2.14.0.rc1.383.gd1ce394fe2-goog
