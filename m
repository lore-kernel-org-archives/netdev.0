From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 7366] New: BUG: unable to handle kernel paging
 request at virtual address d0cb03e0
Date: Mon, 16 Oct 2006 15:06:07 +0200
Message-ID: <453383BF.1040203@trash.net>
References: <200610152100.k9FL0XCW014322@fire-2.osdl.org> <20061015220952.08dde7b3.akpm@osdl.org> <45331B93.7000006@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090001000602020008080405"
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:6075 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S1750774AbWJPNGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 09:06:17 -0400
To: cristi@itz.ro
In-Reply-To: <45331B93.7000006@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090001000602020008080405
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Please use reply to _all_. Quoting manually ..

Patrick McHardy wrote:
>> Does it also happen without external patches like ipp2p? Did you
>> load/unload any netfilter modules before?
>
> This happens after loading all specific, ip_conntrackmodules, flushing
> al iptables rules, reseting counters, flushing all tables, unloading all
> ip_conntrack modules and the runing command <iptables -A INPUT -i eth1
> -j ACCEPT> . Tested also with kernel 2.6.18.1 and it works ok. I do not
> thik this has to do anything with  ipp2p
> module, since is not even used, and in the commands I used,  is not
> specified a command for this module.


Any chance you're also unloading iptables modules? If so this patch
(already in Dave's queue) should fix it ..


--------------090001000602020008080405
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: fix cut-and-paste error in exit functions

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c7b1507f3c040c02efa1b955f7180a33a232c4d9
tree fd21258deca0e5d8859271bb2c745302ce5a1e2a
parent 26da6cf44bc574d528d715a17e48f54da061c151
author Patrick McHardy <kaber@trash.net> Wed, 11 Oct 2006 08:35:50 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 11 Oct 2006 08:35:50 +0200

 net/netfilter/xt_NFQUEUE.c  |    2 +-
 net/netfilter/xt_connmark.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index db9b896..39e1175 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -68,7 +68,7 @@ static int __init xt_nfqueue_init(void)
 
 static void __exit xt_nfqueue_fini(void)
 {
-	xt_register_targets(xt_nfqueue_target, ARRAY_SIZE(xt_nfqueue_target));
+	xt_unregister_targets(xt_nfqueue_target, ARRAY_SIZE(xt_nfqueue_target));
 }
 
 module_init(xt_nfqueue_init);
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index 92a5726..a8f0305 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -147,7 +147,7 @@ static int __init xt_connmark_init(void)
 
 static void __exit xt_connmark_fini(void)
 {
-	xt_register_matches(xt_connmark_match, ARRAY_SIZE(xt_connmark_match));
+	xt_unregister_matches(xt_connmark_match, ARRAY_SIZE(xt_connmark_match));
 }
 
 module_init(xt_connmark_init);

--------------090001000602020008080405--
