From: James Morris <jmorris@intercode.com.au>
Subject: Re: Fwd: tcp seq nr wrapping bug + patch
Date: Tue, 11 Mar 2003 23:40:05 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0303112337410.31542-100000@blackbird.intercode.com.au>
References: <se6cba6e.014@mailhost.newtec.be>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ulrik De Bie <ulrik.debie@newtec.be>, <a@oo.ms>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <se6cba6e.014@mailhost.newtec.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 10 Mar 2003, Ulrik De Bie wrote:

> I resend this patch which fixes a stupid mistake in the tcp sequence
> number in the 2.2 kernel.

This looks good, thanks.

Alan, please apply.


- James
-- 
James Morris
<jmorris@intercode.com.au>


diff -urN -X dontdiff linux-2.2.24.orig/net/ipv4/tcp.c linux-2.2.24.w1/net/ipv4/tcp.c
--- linux-2.2.24.orig/net/ipv4/tcp.c	Wed Sep 25 00:06:26 2002
+++ linux-2.2.24.w1/net/ipv4/tcp.c	Tue Mar 11 23:26:00 2003
@@ -823,7 +823,7 @@
 				 */
 				if (skb_tailroom(skb) > 0 &&
 				    (mss_now - copy) > 0 &&
-				    tp->snd_nxt < TCP_SKB_CB(skb)->end_seq) {
+				    before(tp->snd_nxt, TCP_SKB_CB(skb)->end_seq)) {
 					int last_byte_was_odd = (copy % 4);
 
 					/* 
