From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.1-mm4
Date: Sat, 17 Jan 2004 21:55:35 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040117215535.0e4674b8.akpm@osdl.org>
References: <20040115225948.6b994a48.akpm@osdl.org>
	<20040118001217.GE3125@werewolf.able.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "J.A. Magallon" <jamagallon@able.es>
In-Reply-To: <20040118001217.GE3125@werewolf.able.es>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"J.A. Magallon" <jamagallon@able.es> wrote:
>
> On 01.16, Andrew Morton wrote:
>  > 
>  > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1/2.6.1-mm4/
>  > 
>  > 
> 
>  Net driver problem:
> 
>  werewolf:/etc# modprobe --verbose 3c59x
>  insmod /lib/modules/2.6.1-jam4/kernel/drivers/net/3c59x.ko 
>  FATAL: Error inserting 3c59x (/lib/modules/2.6.1-jam4/kernel/drivers/net/3c59x.ko): Invalid argument

hmm, cute.

--- 25/drivers/net/3c59x.c~3c59x-modprobe-fix	2004-01-17 21:49:14.000000000 -0800
+++ 25-akpm/drivers/net/3c59x.c	2004-01-17 21:49:18.000000000 -0800
@@ -211,11 +211,11 @@
 /* Set the copy breakpoint for the copy-only-tiny-frames scheme.
    Setting to > 1512 effectively disables this feature. */
 #ifndef __arm__
-static const int rx_copybreak = 200;
+static int rx_copybreak = 200;
 #else
 /* ARM systems perform better by disregarding the bus-master
    transfer capability of these cards. -- rmk */
-static const int rx_copybreak = 1513;
+static int rx_copybreak = 1513;
 #endif
 /* Allow setting MTU to a larger size, bypassing the normal ethernet setup. */
 static const int mtu = 1500;

_
