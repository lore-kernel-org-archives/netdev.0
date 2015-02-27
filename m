From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 08/10] x86: unexport set_memory_ro and set_memory_rw
Date: Fri, 27 Feb 2015 15:55:40 +0100
Message-ID: <a064393a0a5d319eebde5c761cfd743132d4f213.1425040940.git.daniel@iogearbox.net>
References: <cover.1425040939.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1425040939.git.daniel@iogearbox.net>
In-Reply-To: <cover.1425040939.git.daniel@iogearbox.net>
References: <cover.1425040939.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This effectively unexports set_memory_ro and set_memory_rw functions, and
thus reverts a03352d2c1dc ("x86: export set_memory_ro and set_memory_rw").

They have been introduced for debugging purposes in e1000e, but no module
user is in mainline kernel (anymore?) and we explicitly do not want modules
to use these functions, as they i.e. protect eBPF (interpreted & JIT'ed)
images from malicious modifications or bugs.

Outside of eBPF scope, I believe also other set_memory_* functions should
be unexported on x86 for modules.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Bruce Allan <bruce.w.allan@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/x86/mm/pageattr.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 536ea2f..81e8282 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1654,13 +1654,11 @@ int set_memory_ro(unsigned long addr, int numpages)
 {
 	return change_page_attr_clear(&addr, numpages, __pgprot(_PAGE_RW), 0);
 }
-EXPORT_SYMBOL_GPL(set_memory_ro);
 
 int set_memory_rw(unsigned long addr, int numpages)
 {
 	return change_page_attr_set(&addr, numpages, __pgprot(_PAGE_RW), 0);
 }
-EXPORT_SYMBOL_GPL(set_memory_rw);
 
 int set_memory_np(unsigned long addr, int numpages)
 {
-- 
1.9.3
