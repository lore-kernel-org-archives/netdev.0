From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPSEC
Date: Tue, 08 Mar 2005 18:44:39 +0100
Message-ID: <422DE487.5020800@trash.net>
References: <Pine.LNX.4.61.0503081706560.11525@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030604010306070804050703"
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
To: Steve Hill <steve@services.navaho.net>
In-Reply-To: <Pine.LNX.4.61.0503081706560.11525@sorbus2.navaho>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030604010306070804050703
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Steve Hill wrote:

> then the ESP SA is added and it has the same sequence number (1) as the 
> AH SA so the AH SA gets deleted.
> 
> The xfrm_state_add() function does:
>         x1 = __xfrm_find_acq_byseq(x->km.seq);
>         ...
>         xfrm_state_delete(x1);
> And this is responsible for deleting the AH SA due to it's matching 
> sequence number.

This is a bug in the kernel, __xfrm_find_acq_byseq should only return
XFRM_STATE_ACQ states. This patch should fix it.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------030604010306070804050703
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/xfrm/xfrm_state.c 1.55 vs edited =====
--- 1.55/net/xfrm/xfrm_state.c	2005-03-07 06:23:53 +01:00
+++ edited/net/xfrm/xfrm_state.c	2005-03-08 18:42:13 +01:00
@@ -609,7 +609,7 @@
 
 	for (i = 0; i < XFRM_DST_HSIZE; i++) {
 		list_for_each_entry(x, xfrm_state_bydst+i, bydst) {
-			if (x->km.seq == seq) {
+			if (x->km.seq == seq && x->km.state == XFRM_STATE_ACQ) {
 				xfrm_state_hold(x);
 				return x;
 			}

--------------030604010306070804050703--
