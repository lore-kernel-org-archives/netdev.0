From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: ipsec hang
Date: Tue, 30 Nov 2004 00:54:39 +0100
Message-ID: <41ABB6BF.4080205@trash.net>
References: <E1CXGlt-00069n-00@gondolin.me.apana.org.au> <41A5D1CF.10504@trash.net> <41ABA014.4090309@crowellsystems.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020605010005050707010805"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        James Morris <jmorris@redhat.com>, akpm@osdl.org, netdev@oss.sgi.com,
        mg@iceni.pl
Return-path: <netdev-bounce@oss.sgi.com>
To: Bill Crowell <bill@crowellsystems.com>
In-Reply-To: <41ABA014.4090309@crowellsystems.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020605010005050707010805
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Bill Crowell wrote:

> Re the bk12, is there just 1 patch that I should install to 2.6.10-rc2 
> to test IPSec? If I don't fiddle with the mm code, we might be able to 
> make some progress on this part. I just love simultaneous equations 
> with 1000 or more variables... ;-)

Patch is attached.

Regards
Patrick



--------------020605010005050707010805
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/23 18:21:09-08:00 kaber@trash.net 
#   [XFRM]: Fix endless loop in xfrm_policy_insert
#   
#   The patch 'Fix policy update bug when increasing
#   priority of last policy' broke this, when a policy
#   with lower priority than an existing policy is inserted
#   xfrm_policy_insert loops forever.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/xfrm/xfrm_policy.c
#   2004/11/23 18:20:49-08:00 kaber@trash.net +1 -0
#   [XFRM]: Fix endless loop in xfrm_policy_insert
#   
#   The patch 'Fix policy update bug when increasing
#   priority of last policy' broke this, when a policy
#   with lower priority than an existing policy is inserted
#   xfrm_policy_insert loops forever.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
diff -Nru a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c	2004-11-30 00:51:18 +01:00
+++ b/net/xfrm/xfrm_policy.c	2004-11-30 00:51:18 +01:00
@@ -353,6 +353,7 @@
 			newpos = p;
 		if (delpol)
 			break;
+		p = &pol->next;
 	}
 	if (newpos)
 		p = newpos;

--------------020605010005050707010805--
