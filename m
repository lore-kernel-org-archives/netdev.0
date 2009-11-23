From: Patrick McHardy <kaber@trash.net>
Subject: netfilter: xt_limit: fix invalid return code in limit_mt_check()
Date: Mon, 23 Nov 2009 13:43:57 +0100
Message-ID: <4B0A838D.3020907@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080903000200030509070600"
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080903000200030509070600
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

This patch fixes an invalid return value in the limit match.
Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!

--------------080903000200030509070600
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 8fa539bd911e8a7faa7cd77b5192229c9666d9b8
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Nov 23 13:37:23 2009 +0100

    netfilter: xt_limit: fix invalid return code in limit_mt_check()
    
    Commit acc738fe (netfilter: xtables: avoid pointer to self) introduced
    an invalid return value in limit_mt_check().
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
index 2e8089e..2773be6 100644
--- a/net/netfilter/xt_limit.c
+++ b/net/netfilter/xt_limit.c
@@ -112,7 +112,7 @@ static bool limit_mt_check(const struct xt_mtchk_param *par)
 
 	priv = kmalloc(sizeof(*priv), GFP_KERNEL);
 	if (priv == NULL)
-		return -ENOMEM;
+		return false;
 
 	/* For SMP, we only want to use one set of state. */
 	r->master = priv;

--------------080903000200030509070600--
