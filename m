From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] skfp: remove assignment expression in conditional (sparse)(v2)
Date: Fri, 15 Oct 2004 14:50:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41704636.7040402@osdl.org>
References: <4169BB68.7030206@osdl.org> <41702405.6070100@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000703060209030807000409"
Cc: netdev <netdev@oss.sgi.com>, mlindner@syskonnect.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <41702405.6070100@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000703060209030807000409
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

> I would prefer to fix a 'assignment expression in conditional' warning 
> by splitting the assignment and the test.
> 
>     Jeff

OK, here you are.

-- 
~Randy

--------------000703060209030807000409
Content-Type: text/x-patch;
 name="skfp_expr_v2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="skfp_expr_v2.patch"


Fix sparse warning:
drivers/net/skfp/hwmtm.c:1904:20: warning: assignment expression in conditional

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>


diffstat:=
 drivers/net/skfp/hwmtm.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff -Naurp ./drivers/net/skfp/hwmtm.c~skfp_expr ./drivers/net/skfp/hwmtm.c
--- ./drivers/net/skfp/hwmtm.c~skfp_expr	2004-08-13 22:36:59.000000000 -0700
+++ ./drivers/net/skfp/hwmtm.c	2004-10-15 14:47:41.942720928 -0700
@@ -1901,7 +1901,8 @@ void smt_send_mbuf(struct s_smc *smc, SM
 	}
 
 	if (!smc->hw.mac_ring_is_up || frag_count > queue->tx_free) {
-		if (frame_status &= ~LAN_TX) {
+		frame_status &= ~LAN_TX;
+		if (frame_status) {
 			DB_TX("Ring is down: terminate LAN_TX",0,0,2) ;
 		}
 		else {

--------------000703060209030807000409--
