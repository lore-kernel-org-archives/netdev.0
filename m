From: Andi Kleen <ak@suse.de>
Subject: [PATCH RFC] [5/9] modpost: Fix a buffer overflow in modpost
Date: Thu, 22 Nov 2007 03:43:10 +0100 (CET)
Message-ID: <20071122024310.BB7E414D68@wotan.suse.de>
References: <20071122343.446909000@suse.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:58879 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751643AbXKVCnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 21:43:12 -0500
In-Reply-To: <20071122343.446909000@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When passing an file name > 1k the stack could be overflowed.
Not really a security issue, but still better plugged.


---
 scripts/mod/modpost.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux/scripts/mod/modpost.c
===================================================================
--- linux.orig/scripts/mod/modpost.c
+++ linux/scripts/mod/modpost.c
@@ -1656,7 +1656,6 @@ int main(int argc, char **argv)
 {
 	struct module *mod;
 	struct buffer buf = { };
-	char fname[SZ];
 	char *kernel_read = NULL, *module_read = NULL;
 	char *dump_write = NULL;
 	int opt;
@@ -1709,6 +1708,8 @@ int main(int argc, char **argv)
 	err = 0;
 
 	for (mod = modules; mod; mod = mod->next) {
+		char fname[strlen(mod->name) + 10];
+
 		if (mod->skip)
 			continue;
 
