From: jamal <hadi@cyberus.ca>
Subject: patch: tc action cleanups
Date: 16 Jan 2005 13:20:37 -0500
Message-ID: <1105899636.1090.794.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-KwjpUM+Nmidz8vQocrKB"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-KwjpUM+Nmidz8vQocrKB
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Heres one i think you didnt resurect Patrick. If ok, Dave please apply.
Other than that i cant seem to find anything at issue with the core
(havent looked at the individual actions other than to follow changed
code from the core).
Very well done.

cheers,
jamal





--=-KwjpUM+Nmidz8vQocrKB
Content-Disposition: attachment; filename=bl_p
Content-Type: text/plain; name=bl_p; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/include/net/pkt_act.h	2005/01/16 13:13:47	1.1
+++ b/include/net/pkt_act.h	2005/01/16 13:15:12
@@ -223,8 +223,10 @@
 	struct tcf_st *p = NULL;
 	if (index && (p = tcf_hash_lookup(index)) != NULL) {
 		if (bind) {
+			spin_lock_bh(&p->lock);
 			p->bindcnt++;
 			p->refcnt++;
+			spin_unlock_bh(&p->lock);
 		}
 		a->priv = p;
 	}

--=-KwjpUM+Nmidz8vQocrKB--
