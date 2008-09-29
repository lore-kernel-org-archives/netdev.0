From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH] x86: export set_memory_ro and set_memory_rw
Date: Mon, 29 Sep 2008 14:39:21 -0700
Message-ID: <20080929213921.20384.77770.stgit@jbrandeb-bw.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com
To: mingo@elte.hu, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57312 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751602AbYI2VjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2008 17:39:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Export set_memory_ro() and set_memory_rw() calls for use by drivers that need
to have more debug information about who might be writing to memory space.
this was initially developed for use while debugging a memory corruption
problem with e1000e.

Ingo Molnar <mingo@elte.hu> said:
>> +EXPORT_SYMBOL(set_memory_rw);
> that's fine, as long as you make it kernel-internal EXPORT_SYMBOL_GPL()

patch was modified with this suggestion.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Acked-by: Ingo Molnar <mingo@elte.hu>
---

 arch/x86/mm/pageattr.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 43e2f84..62c1eef 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -906,11 +906,13 @@ int set_memory_ro(unsigned long addr, int numpages)
 {
 	return change_page_attr_clear(addr, numpages, __pgprot(_PAGE_RW));
 }
+EXPORT_SYMBOL_GPL(set_memory_ro);
 
 int set_memory_rw(unsigned long addr, int numpages)
 {
 	return change_page_attr_set(addr, numpages, __pgprot(_PAGE_RW));
 }
+EXPORT_SYMBOL_GPL(set_memory_rw);
 
 int set_memory_np(unsigned long addr, int numpages)
 {

