From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 20/29] uml: rename arch/um remove_mapping()
Date: Wed, 21 Feb 2007 15:43:24 +0100
Message-ID: <20070221144843.497228000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55018 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965365AbXBUPcy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 10:32:54 -0500
Content-Disposition: inline; filename=uml_remove_mapping.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When 'include/linux/mm.h' includes 'include/linux/swap.h', the global
remove_mapping() definition clashes with the arch/um one.

Rename the arch/um one.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Jeff Dike <jdike@addtoit.com>
---
 arch/um/kernel/physmem.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6-git/arch/um/kernel/physmem.c
===================================================================
--- linux-2.6-git.orig/arch/um/kernel/physmem.c	2007-02-12 09:40:47.000000000 +0100
+++ linux-2.6-git/arch/um/kernel/physmem.c	2007-02-12 11:17:47.000000000 +0100
@@ -160,7 +160,7 @@ int physmem_subst_mapping(void *virt, in
 
 static int physmem_fd = -1;
 
-static void remove_mapping(struct phys_desc *desc)
+static void um_remove_mapping(struct phys_desc *desc)
 {
 	void *virt = desc->virt;
 	int err;
@@ -184,7 +184,7 @@ int physmem_remove_mapping(void *virt)
 	if(desc == NULL)
 		return 0;
 
-	remove_mapping(desc);
+	um_remove_mapping(desc);
 	return 1;
 }
 
@@ -205,7 +205,7 @@ void physmem_forget_descriptor(int fd)
 		page = list_entry(ele, struct phys_desc, list);
 		offset = page->offset;
 		addr = page->virt;
-		remove_mapping(page);
+		um_remove_mapping(page);
 		err = os_seek_file(fd, offset);
 		if(err)
 			panic("physmem_forget_descriptor - failed to seek "

-- 

