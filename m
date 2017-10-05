From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v4 1/3] tools: rename tools/net directory to tools/bpf
Date: Wed,  4 Oct 2017 20:10:03 -0700
Message-ID: <20171005031005.15364-2-jakub.kicinski@netronome.com>
References: <20171005031005.15364-1-jakub.kicinski@netronome.com>
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        dsahern@gmail.com, oss-drivers@netronome.com, brouer@redhat.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:44512 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751259AbdJEDKZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 23:10:25 -0400
Received: by mail-pg0-f54.google.com with SMTP id b1so6072806pge.1
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 20:10:25 -0700 (PDT)
In-Reply-To: <20171005031005.15364-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently only have BPF tools in the tools/net directory.
We are about to add more BPF tools there, not necessarily
networking related, rename the directory and related Makefile
targets to bpf.

Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 MAINTAINERS                         |  3 +--
 tools/Makefile                      | 14 +++++++-------
 tools/{net => bpf}/Makefile         |  0
 tools/{net => bpf}/bpf_asm.c        |  0
 tools/{net => bpf}/bpf_dbg.c        |  0
 tools/{net => bpf}/bpf_exp.l        |  0
 tools/{net => bpf}/bpf_exp.y        |  0
 tools/{net => bpf}/bpf_jit_disasm.c |  0
 8 files changed, 8 insertions(+), 9 deletions(-)
 rename tools/{net => bpf}/Makefile (100%)
 rename tools/{net => bpf}/bpf_asm.c (100%)
 rename tools/{net => bpf}/bpf_dbg.c (100%)
 rename tools/{net => bpf}/bpf_exp.l (100%)
 rename tools/{net => bpf}/bpf_exp.y (100%)
 rename tools/{net => bpf}/bpf_jit_disasm.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5231392cf4bd..004816a585b8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2725,7 +2725,7 @@ F:	net/core/filter.c
 F:	net/sched/act_bpf.c
 F:	net/sched/cls_bpf.c
 F:	samples/bpf/
-F:	tools/net/bpf*
+F:	tools/bpf/
 F:	tools/testing/selftests/bpf/
 
 BROADCOM B44 10/100 ETHERNET DRIVER
@@ -9416,7 +9416,6 @@ F:	include/uapi/linux/in.h
 F:	include/uapi/linux/net.h
 F:	include/uapi/linux/netdevice.h
 F:	include/uapi/linux/net_namespace.h
-F:	tools/net/
 F:	tools/testing/selftests/net/
 F:	lib/random32.c
 
diff --git a/tools/Makefile b/tools/Makefile
index 9dfede37c8ff..df6fcb293fbc 100644
--- a/tools/Makefile
+++ b/tools/Makefile
@@ -19,7 +19,7 @@ include scripts/Makefile.include
 	@echo '  kvm_stat               - top-like utility for displaying kvm statistics'
 	@echo '  leds                   - LEDs  tools'
 	@echo '  liblockdep             - user-space wrapper for kernel locking-validator'
-	@echo '  net                    - misc networking tools'
+	@echo '  bpf                    - misc BPF tools'
 	@echo '  perf                   - Linux performance measurement and analysis tool'
 	@echo '  selftests              - various kernel selftests'
 	@echo '  spi                    - spi tools'
@@ -57,7 +57,7 @@ acpi: FORCE
 cpupower: FORCE
 	$(call descend,power/$@)
 
-cgroup firewire hv guest spi usb virtio vm net iio gpio objtool leds: FORCE
+cgroup firewire hv guest spi usb virtio vm bpf iio gpio objtool leds: FORCE
 	$(call descend,$@)
 
 liblockdep: FORCE
@@ -91,7 +91,7 @@ kvm_stat: FORCE
 
 all: acpi cgroup cpupower gpio hv firewire liblockdep \
 		perf selftests spi turbostat usb \
-		virtio vm net x86_energy_perf_policy \
+		virtio vm bpf x86_energy_perf_policy \
 		tmon freefall iio objtool kvm_stat
 
 acpi_install:
@@ -100,7 +100,7 @@ all: acpi cgroup cpupower gpio hv firewire liblockdep \
 cpupower_install:
 	$(call descend,power/$(@:_install=),install)
 
-cgroup_install firewire_install gpio_install hv_install iio_install perf_install spi_install usb_install virtio_install vm_install net_install objtool_install:
+cgroup_install firewire_install gpio_install hv_install iio_install perf_install spi_install usb_install virtio_install vm_install bpf_install objtool_install:
 	$(call descend,$(@:_install=),install)
 
 liblockdep_install:
@@ -124,7 +124,7 @@ all: acpi cgroup cpupower gpio hv firewire liblockdep \
 install: acpi_install cgroup_install cpupower_install gpio_install \
 		hv_install firewire_install iio_install liblockdep_install \
 		perf_install selftests_install turbostat_install usb_install \
-		virtio_install vm_install net_install x86_energy_perf_policy_install \
+		virtio_install vm_install bpf_install x86_energy_perf_policy_install \
 		tmon_install freefall_install objtool_install kvm_stat_install
 
 acpi_clean:
@@ -133,7 +133,7 @@ install: acpi_install cgroup_install cpupower_install gpio_install \
 cpupower_clean:
 	$(call descend,power/cpupower,clean)
 
-cgroup_clean hv_clean firewire_clean spi_clean usb_clean virtio_clean vm_clean net_clean iio_clean gpio_clean objtool_clean leds_clean:
+cgroup_clean hv_clean firewire_clean spi_clean usb_clean virtio_clean vm_clean bpf_clean iio_clean gpio_clean objtool_clean leds_clean:
 	$(call descend,$(@:_clean=),clean)
 
 liblockdep_clean:
@@ -169,7 +169,7 @@ install: acpi_install cgroup_install cpupower_install gpio_install \
 
 clean: acpi_clean cgroup_clean cpupower_clean hv_clean firewire_clean \
 		perf_clean selftests_clean turbostat_clean spi_clean usb_clean virtio_clean \
-		vm_clean net_clean iio_clean x86_energy_perf_policy_clean tmon_clean \
+		vm_clean bpf_clean iio_clean x86_energy_perf_policy_clean tmon_clean \
 		freefall_clean build_clean libbpf_clean libsubcmd_clean liblockdep_clean \
 		gpio_clean objtool_clean leds_clean
 
diff --git a/tools/net/Makefile b/tools/bpf/Makefile
similarity index 100%
rename from tools/net/Makefile
rename to tools/bpf/Makefile
diff --git a/tools/net/bpf_asm.c b/tools/bpf/bpf_asm.c
similarity index 100%
rename from tools/net/bpf_asm.c
rename to tools/bpf/bpf_asm.c
diff --git a/tools/net/bpf_dbg.c b/tools/bpf/bpf_dbg.c
similarity index 100%
rename from tools/net/bpf_dbg.c
rename to tools/bpf/bpf_dbg.c
diff --git a/tools/net/bpf_exp.l b/tools/bpf/bpf_exp.l
similarity index 100%
rename from tools/net/bpf_exp.l
rename to tools/bpf/bpf_exp.l
diff --git a/tools/net/bpf_exp.y b/tools/bpf/bpf_exp.y
similarity index 100%
rename from tools/net/bpf_exp.y
rename to tools/bpf/bpf_exp.y
diff --git a/tools/net/bpf_jit_disasm.c b/tools/bpf/bpf_jit_disasm.c
similarity index 100%
rename from tools/net/bpf_jit_disasm.c
rename to tools/bpf/bpf_jit_disasm.c
-- 
2.14.1
