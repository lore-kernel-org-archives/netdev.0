From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Second 3c509 missing (2.5.71 thru 2.6.0-t7)
Date: Fri, 10 Oct 2003 12:48:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031010124849.5ae48bd9.shemminger@osdl.org>
References: <200310100126.VAA21162@clem.clem-digital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Pete Clements <clem@clem.clem-digital.net>, netdev@oss.sgi.com
In-Reply-To: <200310100126.VAA21162@clem.clem-digital.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Oct 2003 21:26:01 -0400 (EDT)
Pete Clements <clem@clem.clem-digital.net> wrote:

> Since things are moving into fixes...
> 
> I use 3c509 compiled in. Second card not detected. This has been the
> case with the stock kernel since 2.5.71.  Have been replacing the
> code for all kernels since .70.  Have not tried as modules.

Try this.

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Fri Oct 10 10:03:42 2003
+++ b/drivers/net/Space.c	Fri Oct 10 10:03:42 2003
@@ -433,17 +433,15 @@
 	
 #ifdef CONFIG_SBNI
 	for (num = 0; num < 8; ++num)
-		if (sbni_probe(num))
-			break;
+		sbni_probe(num);
 #endif
 #ifdef CONFIG_TR
 	for (num = 0; num < 8; ++num)
-		if (trif_probe(num))
-			break;
+		trif_probe(num);
 #endif
 	for (num = 0; num < 8; ++num)
-		if (ethif_probe(num))
-			break;
+		ethif_probe(num);
+
 #ifdef CONFIG_COPS
 	cops_probe(0);
 	cops_probe(1);
