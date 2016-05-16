From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] ss: Tell user about -EOPNOTSUPP for SOCK_DESTROY
Date: Mon, 16 May 2016 16:53:11 -0700
Message-ID: <1463442791-2399-2-git-send-email-dsa@cumulusnetworks.com>
References: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36700 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbcEPXxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 19:53:21 -0400
Received: by mail-pa0-f53.google.com with SMTP id bt5so68988179pac.3
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 16:53:21 -0700 (PDT)
In-Reply-To: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Silent failures are not friendly to the user. If a command is
not supported tell the user about it.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 misc/ss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 23fff19d9199..bd7214c85938 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2264,7 +2264,7 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
 	if (!(diag_arg->f->families & (1 << r->idiag_family)))
 		return 0;
 	if (diag_arg->f->kill && kill_inet_sock(h, arg) != 0) {
-		if (errno == EOPNOTSUPP || errno == ENOENT) {
+		if (errno == ENOENT) {
 			/* Socket can't be closed, or is already closed. */
 			return 0;
 		} else {
-- 
2.1.4
