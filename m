From: Andi Kleen <ak@suse.de>
Subject: [PATCH RFC] [4/9] modpost: Fix format string warnings
Date: Thu, 22 Nov 2007 03:43:09 +0100 (CET)
Message-ID: <20071122024309.AD8E314D68@wotan.suse.de>
References: <20071122343.446909000@suse.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:58875 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751153AbXKVCnK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 21:43:10 -0500
In-Reply-To: <20071122343.446909000@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fix wrong format strings in modpost exposed by the previous patch.
Including one missing argument -- some random data was printed instead.

---
 scripts/mod/modpost.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

Index: linux/scripts/mod/modpost.c
===================================================================
--- linux.orig/scripts/mod/modpost.c
+++ linux/scripts/mod/modpost.c
@@ -388,7 +388,7 @@ static int parse_elf(struct elf_info *in
 
 	/* Check if file offset is correct */
 	if (hdr->e_shoff > info->size) {
-		fatal("section header offset=%u in file '%s' is bigger then filesize=%lu\n", hdr->e_shoff, filename, info->size);
+		fatal("section header offset=%lu in file '%s' is bigger then filesize=%lu\n", (unsigned long)hdr->e_shoff, filename, info->size);
 		return 0;
 	}
 
@@ -409,7 +409,7 @@ static int parse_elf(struct elf_info *in
 		const char *secname;
 
 		if (sechdrs[i].sh_offset > info->size) {
-			fatal("%s is truncated. sechdrs[i].sh_offset=%u > sizeof(*hrd)=%ul\n", filename, (unsigned int)sechdrs[i].sh_offset, sizeof(*hdr));
+			fatal("%s is truncated. sechdrs[i].sh_offset=%lu > sizeof(*hrd)=%lu\n", filename, (unsigned long)sechdrs[i].sh_offset, sizeof(*hdr));
 			return 0;
 		}
 		secname = secstrings + sechdrs[i].sh_name;
@@ -907,7 +907,8 @@ static void warn_sec_mismatch(const char
 		     "before '%s' (at offset -0x%llx)\n",
 		     modname, fromsec, (unsigned long long)r.r_offset,
 		     secname, refsymname,
-		     elf->strtab + after->st_name);
+		     elf->strtab + after->st_name,
+		     (unsigned long long)r.r_offset);
 	} else {
 		warn("%s(%s+0x%llx): Section mismatch: reference to %s:%s\n",
 		     modname, fromsec, (unsigned long long)r.r_offset,
