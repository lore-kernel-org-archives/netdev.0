From: "Maciej W. Rozycki" <macro@ds2.pg.gda.pl>
Subject: Re: [PATCH] Fix warnings in defxx.c
Date: Tue, 7 Oct 2003 20:15:04 +0200 (MET DST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.3.96.1031007200222.13842A-100000@delta.ds2.pg.gda.pl>
References: <20031007175535.GA1743@averell>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20031007175535.GA1743@averell>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 7 Oct 2003, Andi Kleen wrote:

> Fix harmless 64bit warnings in defxx.c
> 
> diff -u linux-2.5-cleanup/drivers/net/defxx.c-o linux-2.5-cleanup/drivers/net/defxx.c
> --- linux-2.5-cleanup/drivers/net/defxx.c-o	2003-08-22 13:35:29.000000000 +0200
> +++ linux-2.5-cleanup/drivers/net/defxx.c	2003-12-02 17:12:55.629162080 +0100
> @@ -2664,8 +2664,8 @@
>   
>  static void my_skb_align(struct sk_buff *skb, int n)
>  {
> -	u32 x=(u32)skb->data;	/* We only want the low bits .. */
> -	u32 v;
> +	unsigned long x=(unsigned long)skb->data;	
> +	unsigned long v;
>  	
>  	v=(x+n-1)&~(n-1);	/* Where we want to be */

 Thanks for the fix.  I have a 64-bit system to test the driver at the run
time (for both endiannesses, even), so in a long run I'm going to keep an
eye on such bits.

-- 
+  Maciej W. Rozycki, Technical University of Gdansk, Poland   +
+--------------------------------------------------------------+
+        e-mail: macro@ds2.pg.gda.pl, PGP key available        +
