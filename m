From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: PATCH: [LLC] set mac.raw if tr_source_route is called
Date: Wed, 06 Oct 2004 18:58:32 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41646A88.4050609@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040304090308000805060400"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040304090308000805060400
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Here is the fix for the problem Thomas pointed out, its at
the usual place:

bk://kernel.bkbits.net/acme/sk_buff-2.6

- Arnaldo

--------------040304090308000805060400
Content-Type: text/plain;
 name="tr_hdr-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tr_hdr-fix.patch"

===================================================================


ChangeSet@1.2057, 2004-10-06 18:51:11-03:00, acme@conectiva.com.br
  [LLC] set mac.raw if tr_source_route is called
  
  Thanks to Thomas Graf for spotting this.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 llc_output.c |    1 +
 1 files changed, 1 insertion(+)


diff -Nru a/net/llc/llc_output.c b/net/llc/llc_output.c
--- a/net/llc/llc_output.c	2004-10-06 18:56:17 -03:00
+++ b/net/llc/llc_output.c	2004-10-06 18:56:17 -03:00
@@ -51,6 +51,7 @@
 		if (da) {
 			memcpy(trh->daddr, da, dev->addr_len);
 			tr_source_route(skb, trh, dev);
+			skb->mac.raw = skb->data;
 		}
 		break;
 	}


--------------040304090308000805060400--
