From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Submission #4  for S2io 10GbE driver
Date: Sat, 20 Mar 2004 05:00:54 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <405C1656.8080004@pobox.com>
References: <001001c40e34$d2c3c4b0$0300a8c0@S2IOtech.com> <405C153A.2020809@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090801020801050302080103"
Cc: netdev@oss.sgi.com, "'ravinandan arakali'" <ravinandan.arakali@s2io.com>,
        raghavendra.koushik@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
In-Reply-To: <405C153A.2020809@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090801020801050302080103
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Jeff Garzik wrote:
> ===== drivers/net/s2io.h 1.1 vs 1.2 =====
> --- 1.1/drivers/net/s2io.h	Sat Mar 20 04:38:16 2004
> +++ 1.2/drivers/net/s2io.h	Sat Mar 20 04:47:53 2004
> @@ -14,8 +14,8 @@
>  #define _S2IO_H
>  
>  #define TBD 0
> -#define BIT(loc)        (((u64)0x8000000000000000ULL) >> loc)
> -#define vBIT(val, loc, sz)  (((u64)val) << (64-loc-sz))
> +#define BIT(loc)		(1ULL << (loc))
> +#define vBIT(val, loc, sz)	(((u64)val) << (64-loc-sz))

and here is a patch correcting an incorrect cleanup...


--------------090801020801050302080103
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

===== drivers/net/s2io.h 1.2 vs edited =====
--- 1.2/drivers/net/s2io.h	Sat Mar 20 04:47:53 2004
+++ edited/drivers/net/s2io.h	Sat Mar 20 04:59:28 2004
@@ -14,7 +14,7 @@
 #define _S2IO_H
 
 #define TBD 0
-#define BIT(loc)		(1ULL << (loc))
+#define BIT(loc)		(0x8000000000000000ULL >> (loc))
 #define vBIT(val, loc, sz)	(((u64)val) << (64-loc-sz))
 
 #ifndef BOOL

--------------090801020801050302080103--
