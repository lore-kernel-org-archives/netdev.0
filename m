From: takada <takada@mbf.nifty.com>
Subject: Re: MediaGX/GeodeGX1 requires X86_OOSTORE.
Date: Tue, 20 Feb 2007 20:34:13 +0900 (JST)
Message-ID: <20070220.203413.260790539.takada@mbf.nifty.com>
References: <ada3b5253p0.fsf@cisco.com>
	<20070220.085639.260788422.takada@mbf.nifty.com>
	<20070220000231.GM7585@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, pcnet32@verizon.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lsorense@csclub.uwaterloo.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from pxy2nd.nifty.com ([202.248.175.14]:23248 "HELO pxy2nd.nifty.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932901AbXBTLfT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 06:35:19 -0500
In-Reply-To: <20070220000231.GM7585@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: MediaGX/GeodeGX1 requires X86_OOSTORE.
Date: Mon, 19 Feb 2007 19:02:31 -0500

> On Tue, Feb 20, 2007 at 08:56:39AM +0900, takada wrote:
> > /proc/cpuinfo with MediaGXm :

  :

> > flags		: fpu tsc msr cx8 cmov mmx cxmmx
> > bogomips	: 401.00
> > clflush size	: 32
> 
> Hmm with 2.6.18 I am seeing:

I posted with 2.6.20 + enabled X86_OOSTORE.
The clflush sze line is in /proc/cpuinfo. but clfush is not in flags line.

BTW, can we use WBINVD instruction? I tested compile only.
Do you know a method to change dynamically without #ifdef when it works
with MediaGX/GeodeGX.

diff -Narup a/include/asm-i386/io.h b/include/asm-i386/io.h
--- a/include/asm-i386/io.h	2007-02-20 16:23:25.000000000 +0900
+++ b/include/asm-i386/io.h	2007-02-20 17:07:14.000000000 +0900
@@ -232,7 +232,19 @@ static inline void memcpy_toio(volatile 
  *	2. Accidentally out of order processors (PPro errata #51)
  */
  
-#if defined(CONFIG_X86_OOSTORE) || defined(CONFIG_X86_PPRO_FENCE)
+#ifdef CONFIG_MGEODEGX1
+
+static inline void dma_flush_cache(void)
+{
+	__asm__ __volatile__ ("wbinvd": : :"memory");
+}
+
+#define dma_cache_inv(_start,_size)		dma_flush_cache()
+#define dma_cache_wback(_start,_size)		dma_flush_cache()
+#define dma_cache_wback_inv(_start,_size)	dma_flush_cache()
+#define flush_write_buffers()
+
+#elif defined(CONFIG_X86_OOSTORE) || defined(CONFIG_X86_PPRO_FENCE)
 
 static inline void flush_write_buffers(void)
 {
