From: Joe Perches <joe@perches.com>
Subject: Re: Possible code defects: macros and precedence
Date: Tue, 20 Sep 2016 11:03:44 -0700
Message-ID: <1474394624.1954.45.camel@perches.com>
References: <1472927739.5018.13.camel@perches.com>
         <alpine.DEB.2.10.1609041809260.3178@hadrien>
         <1473001581.5018.37.camel@perches.com>
         <alpine.DEB.2.10.1609172221110.3124@hadrien>
         <1474147658.1954.1.camel@perches.com>
         <alpine.DEB.2.10.1609180702060.3361@hadrien>
         <1474191110.1954.16.camel@perches.com>
         <alpine.DEB.2.10.1609201503260.2914@hadrien>
         <1474391253.1954.39.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Dan Carpenter <error27@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        netdev <netdev@vger.kernel.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474391253.1954.39.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-09-20 at 10:07 -0700, Joe Perches wrote:
> On Tue, 2016-09-20 at 15:14 +0200, Julia Lawall wrote:
> > The semantic patch below finds a binary operator in a macro and a binary
> > operator in the use of the macro, and checks if the priority of the
> > operator in the macro is higher (lower number) than the priority of the
> > operator in the use.  If this is the case, it adds parentheses in the use,
> > which is not what one wants, but serves to show where the problem is

> Thanks, this works on the trivial example I suggested
> without an #include
> 
> I've tried it on trivial files with --recursive-includes
> and it seems to work there too.

I tried it on drivers/net with --recursive-includes and got
just 1 hit on an old and probably relatively untested driver.

No hardware, can't test.  It may be correct now.  Who knows...
---
diff --urN a/drivers/net/ethernet/smsc/smc911x.h b/drivers/net/ethernet/smsc/smc911x.h
--- a/drivers/net/ethernet/smsc/smc911x.h
+++ b/drivers/net/ethernet/smsc/smc911x.h
@@ -700,8 +700,8 @@ static const struct chip_id chip_ids[] =
  * capabilities.  Please use those and not the in/out primitives.
  */
 /* FIFO read/write macros */
-#define SMC_PUSH_DATA(lp, p, l)	SMC_outsl( lp, TX_DATA_FIFO, p, (l) >> 2 )
-#define SMC_PULL_DATA(lp, p, l)	SMC_insl ( lp, RX_DATA_FIFO, p, (l) >> 2 )
+#define SMC_PUSH_DATA(lp, p, l)	SMC_outsl( lp, TX_DATA_FIFO, p, ((l) >> 2) )
+#define SMC_PULL_DATA(lp, p, l)	SMC_insl ( lp, RX_DATA_FIFO, p, ((l) >> 2) )
 #define SMC_SET_TX_FIFO(lp, x) 	SMC_outl( x, lp, TX_DATA_FIFO )
 #define SMC_GET_RX_FIFO(lp)	SMC_inl( lp, RX_DATA_FIFO )
 
