From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: Tue, 21 Sep 2004 19:32:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921193234.1c5b09a1.davem@davemloft.net>
References: <20040918203319.24004d6e.davem@davemloft.net>
	<1095645106.1048.190.camel@jzny.localdomain>
	<20040919195351.0b3560e6.davem@davemloft.net>
	<1095686672.1049.301.camel@jzny.localdomain>
	<20040920121123.70baf895.davem@davemloft.net>
	<20040921034212.GA28462@gondor.apana.org.au>
	<20040920231805.3f18479c.davem@davemloft.net>
	<20040922020729.GA14062@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040922020729.GA14062@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004 12:07:29 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Sep 20, 2004 at 11:18:05PM -0700, David S. Miller wrote:
> >
> > > Yes CONFIG_IP_ROUTE_TOS has out-lived its usefulness.  It has
> > > always seemed half-hearted compared to CONFIG_IP_ROUTE_FWMARK.
> > 
> > Ok, then I'm gonna nuke it.
> 
> Here is a follow-up patch to get rid of the remaining Kconfig references.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I'll apply this, thanks Herbert.

Dang, right after pushing the fib_hash.c cleanup to Linus
I spotted this bug :-/

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/21 16:32:41-07:00 davem@nuts.davemloft.net 
#   [IPV4]: Fix list traversal in fn_hash_insert().
#   
#   Could create an endless loop during route
#   replace operations.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/fib_hash.c
#   2004/09/21 16:31:48-07:00 davem@nuts.davemloft.net +1 -1
#   [IPV4]: Fix list traversal in fn_hash_insert().
# 
diff -Nru a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
--- a/net/ipv4/fib_hash.c	2004-09-21 19:11:44 -07:00
+++ b/net/ipv4/fib_hash.c	2004-09-21 19:11:44 -07:00
@@ -536,7 +536,7 @@
 		 * information.
 		 */
 		fa_orig = fa;
-		list_for_each_entry(fa, fa->fa_list.prev, fa_list) {
+		list_for_each_entry(fa, fa_orig->fa_list.prev, fa_list) {
 			if (fa->fa_info->fib_priority != fi->fib_priority)
 				break;
 			if (fa->fa_type == type &&
