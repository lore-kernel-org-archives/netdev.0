From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Make snd_cwnd_cnt 32-bit
Date: Mon, 15 Oct 2007 18:57:31 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710151856340.3767@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-778396197-1192463851=:3767"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55854 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754650AbXJOP5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 11:57:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-778396197-1192463851=:3767
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Very little point of having 32-bit snd_cnwd if this is not
32-bit as well, as a number of snd_cwnd incrementation formulas
assume that snd_cwnd_cnt can be at least as large as snd_cwnd.

Whether 32-bit is useful was discussed when e0ef57cc56c3c96
was made:
  http://marc.info/?l=linux-netdev&m=117218144409825&w=2

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index c5b94c1..997b349 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -315,7 +315,7 @@ struct tcp_sock {
  */
  	u32	snd_ssthresh;	/* Slow start size threshold		*/
  	u32	snd_cwnd;	/* Sending congestion window		*/
- 	u16	snd_cwnd_cnt;	/* Linear increase counter		*/
+ 	u32	snd_cwnd_cnt;	/* Linear increase counter		*/
 	u32	snd_cwnd_clamp; /* Do not allow snd_cwnd to grow above this */
 	u32	snd_cwnd_used;
 	u32	snd_cwnd_stamp;
-- 
1.5.0.6

k i.
---696243703-778396197-1192463851=:3767--
