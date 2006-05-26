From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] Fixup struct ip_mc_list::multiaddr type
Date: Fri, 26 May 2006 23:30:09 +0400
Message-ID: <20060526193009.GB7266@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:35050 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751318AbWEZT3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 15:29:53 -0400
Received: by nf-out-0910.google.com with SMTP id n29so121352nfc
        for <netdev@vger.kernel.org>; Fri, 26 May 2006 12:29:52 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All users except two expect 32-bit big-endian value. One is of

	->multiaddr = ->multiaddr

variety. And last one is "%08lX".

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/igmp.h |    2 +-
 net/ipv4/igmp.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2361,7 +2361,7 @@ static int igmp_mc_seq_show(struct seq_f
 		}
 
 		seq_printf(seq,
-			   "\t\t\t\t%08lX %5d %d:%08lX\t\t%d\n",
+			   "\t\t\t\t%08X %5d %d:%08lX\t\t%d\n",
 			   im->multiaddr, im->users,
 			   im->tm_running, im->tm_running ?
 			   jiffies_to_clock_t(im->timer.expires-jiffies) : 0,
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -169,7 +169,7 @@ struct ip_sf_list
 struct ip_mc_list
 {
 	struct in_device	*interface;
-	unsigned long		multiaddr;
+	__be32			multiaddr;
 	struct ip_sf_list	*sources;
 	struct ip_sf_list	*tomb;
 	unsigned int		sfmode;

