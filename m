From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master 4/4] tc, bpf: use bind/type macros from gelf
Date: Tue,  2 Feb 2016 01:12:29 +0100
Message-ID: <870f682a1cd851a378315e80afdea6efe68cbdc5.1454370543.git.daniel@iogearbox.net>
References: <cover.1454370543.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41824 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054AbcBBAMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 19:12:46 -0500
In-Reply-To: <cover.1454370543.git.daniel@iogearbox.net>
In-Reply-To: <cover.1454370543.git.daniel@iogearbox.net>
References: <cover.1454370543.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't reimplement them and rather use the macros from the gelf header,
that is, GELF_ST_BIND()/GELF_ST_TYPE().

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/tc_bpf.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 5e80d0f..6a94894 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -1162,9 +1162,6 @@ static int bpf_map_attach(const char *name, const struct bpf_elf_map *map,
 	return fd;
 }
 
-#define __ELF_ST_BIND(x)	((x) >> 4)
-#define __ELF_ST_TYPE(x)	(((unsigned int) x) & 0xf)
-
 static const char *bpf_str_tab_name(const struct bpf_elf_ctx *ctx,
 				    const GElf_Sym *sym)
 {
@@ -1180,8 +1177,8 @@ static const char *bpf_map_fetch_name(struct bpf_elf_ctx *ctx, int which)
 		if (gelf_getsym(ctx->sym_tab, i, &sym) != &sym)
 			continue;
 
-		if (__ELF_ST_BIND(sym.st_info) != STB_GLOBAL ||
-		    __ELF_ST_TYPE(sym.st_info) != STT_NOTYPE ||
+		if (GELF_ST_BIND(sym.st_info) != STB_GLOBAL ||
+		    GELF_ST_TYPE(sym.st_info) != STT_NOTYPE ||
 		    sym.st_shndx != ctx->sec_maps ||
 		    sym.st_value / sizeof(struct bpf_elf_map) != which)
 			continue;
-- 
1.9.3
