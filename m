From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] drivers/isdn: break out of the loop after call isdn_tty_send_msg
Date: Thu, 28 Feb 2013 10:57:32 +0800
Message-ID: <512EC79C.3010700@asianux.com>
References: <512DD2B3.2070404@asianux.com> <512DD94C.2020008@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Greg KH <gregkh@linuxfoundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	netdev <netdev@vger.kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:15701 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190Ab3B1C5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 21:57:53 -0500
In-Reply-To: <512DD94C.2020008@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  need break out of the loop after call isdn_tty_send_msg.
    isdn_tty_send_msg is intended to eat the rest of the string.
    so need not scan again the string which appended "+M...".

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 drivers/isdn/i4l/isdn_tty.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
index d8a7d83..8ac7b33 100644
--- a/drivers/isdn/i4l/isdn_tty.c
+++ b/drivers/isdn/i4l/isdn_tty.c
@@ -3587,7 +3587,7 @@ isdn_tty_parse_at(modem_info *info)
 			case 'M':	/* MESSAGE */
 				p++;
 				isdn_tty_send_msg(info, m, p);
-				break;
+				goto tail;
 			default:
 				PARSE_ERROR;
 			}
@@ -3601,6 +3601,8 @@ isdn_tty_parse_at(modem_info *info)
 			PARSE_ERROR;
 		}
 	}
+
+tail:
 #ifdef CONFIG_ISDN_AUDIO
 	if (!info->vonline)
 #endif
-- 
1.7.7.6
