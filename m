From: "David S. Miller" <davem@davemloft.net>
Subject: Re: ICMP attacks against TCP
Date: Mon, 13 Sep 2004 16:01:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913160133.69185327.davem@davemloft.net>
References: <4.3.2.7.2.20040912223315.00df2890@mail.daleclick.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Fernando Gont <fernando@gont.com.ar>
In-Reply-To: <4.3.2.7.2.20040912223315.00df2890@mail.daleclick.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 12 Sep 2004 22:40:04 -0300
Fernando Gont <fernando@gont.com.ar> wrote:

> There are some other work-arounds (for example, ignoring ICMP Source Quench 
> messages) are not implemented in Linux, though.

I have no problem changing Linux to ignore these ICMP Source Quench
messages, I completely agree with the draft.  I've made the
change in both my 2.4.x and 2.6.x trees as follows:

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/13 15:43:14-07:00 davem@nuts.davemloft.net 
#   [TCP]: Just silently ignore ICMP Source Quench messages.
#   
#   Recommended by draft-gont-tcpm-icmp-attacks-01.txt
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/tcp_ipv4.c
#   2004/09/13 15:42:33-07:00 davem@nuts.davemloft.net +1 -5
#   [TCP]: Just silently ignore ICMP Source Quench messages.
# 
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2004-09-13 15:44:01 -07:00
+++ b/net/ipv4/tcp_ipv4.c	2004-09-13 15:44:01 -07:00
@@ -1033,11 +1033,7 @@
 
 	switch (type) {
 	case ICMP_SOURCE_QUENCH:
-		/* This is deprecated, but if someone generated it,
-		 * we have no reasons to ignore it.
-		 */
-		if (!sock_owned_by_user(sk))
-			tcp_enter_cwr(tp);
+		/* Just silently ignore these. */
 		goto out;
 	case ICMP_PARAMETERPROB:
 		err = EPROTO;
