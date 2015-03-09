From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH 6/8] fs/file: add get_unused_fd_and_install_flags(flags, newfile) api
Date: Mon,  9 Mar 2015 14:20:01 -0700
Message-ID: <1425936003-24544-6-git-send-email-zenczykowski@gmail.com>
References: <CAHo-OozBxw=h--dSjhobVfepC_10=H5_9DvXEvrhtnrFvc5tdw@mail.gmail.com>
 <1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Theodore Ts'o <tytso@mit.edu>, netdev@vger.kernel.org
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:37103 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754140AbbCIVU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 17:20:27 -0400
Received: by igbhn18 with SMTP id hn18so24956269igb.2
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 14:20:27 -0700 (PDT)
In-Reply-To: <1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 fs/file.c            | 7 +++++++
 include/linux/file.h | 2 ++
 2 files changed, 9 insertions(+)

diff --git a/fs/file.c b/fs/file.c
index 01b1e171ce0a..d3e692e99ec5 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -513,6 +513,13 @@ int get_unused_fd_flags(unsigned flags)
 }
 EXPORT_SYMBOL(get_unused_fd_flags);
=20
+int get_unused_fd_and_install_flags(unsigned flags, struct file *newfi=
le)
+{
+	return __alloc_fd(current->files, 0, rlimit(RLIMIT_NOFILE), flags,
+			  newfile);
+}
+EXPORT_SYMBOL(get_unused_fd_and_install_flags);
+
 static void __put_unused_fd(struct files_struct *files, unsigned int f=
d)
 {
 	struct fdtable *fdt =3D files_fdtable(files);
diff --git a/include/linux/file.h b/include/linux/file.h
index f87d30882a24..92b43187aa39 100644
--- a/include/linux/file.h
+++ b/include/linux/file.h
@@ -66,6 +66,8 @@ extern void set_close_on_exec(unsigned int fd, int fl=
ag);
 extern bool get_close_on_exec(unsigned int fd);
 extern void put_filp(struct file *);
 extern int get_unused_fd_flags(unsigned flags);
+extern int get_unused_fd_and_install_flags(unsigned flags,
+	struct file *newfile);
 extern void put_unused_fd(unsigned int fd);
=20
 extern void fd_install(unsigned int fd, struct file *file);
--=20
2.2.0.rc0.207.ga3a616c
