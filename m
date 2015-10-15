From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH iproute2] ss: return -1 if an unrecognized option was given
Date: Thu, 15 Oct 2015 21:01:16 +0200
Message-ID: <1444935676-10068-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:34042 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752514AbbJOTBT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 15:01:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When getopt_long encounters an option which has not been registered, it
returns '?'. React upon that and call usage() instead of help() so ss
returns with a non-zero exit status.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index eca4aa3..a9ae85e 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3770,8 +3770,8 @@ int main(int argc, char *argv[])
 				exit(1);
 			break;
 		case 'h':
-		case '?':
 			help();
+		case '?':
 		default:
 			usage();
 		}
-- 
2.5.0
