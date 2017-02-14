From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH iproute2] devlink: Call dl_free in early exit case
Date: Tue, 14 Feb 2017 07:29:38 +0200
Message-ID: <20170214052938.16727-1-leon@kernel.org>
Cc: linux-netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:39786 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750721AbdBNF3c (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 00:29:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Prior to parsing command options, the devlink tool allocates memory
to store results. In case of early exit (wrong parameters or version
check), this memory wasn't freed.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index 23db9e7c..34a409f7 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -2579,7 +2579,8 @@ int main(int argc, char **argv)
 		switch (opt) {
 		case 'V':
 			printf("devlink utility, iproute2-ss%s\n", SNAPSHOT);
-			return EXIT_SUCCESS;
+			ret = EXIT_SUCCESS;
+			goto dl_free;
 		case 'n':
 			dl->no_nice_names = true;
 			break;
@@ -2592,7 +2593,8 @@ int main(int argc, char **argv)
 		default:
 			pr_err("Unknown option.\n");
 			help();
-			return EXIT_FAILURE;
+			ret = EXIT_FAILURE;
+			goto dl_free;
 		}
 	}
