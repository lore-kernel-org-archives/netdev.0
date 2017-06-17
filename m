From: Dave Watson <davejwatson@fb.com>
Subject: [PATCH net-next] tls: update Kconfig
Date: Sat, 17 Jun 2017 08:25:13 -0700
Message-ID: <20170617152513.GA45696@davejwatson-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <kbuild-all@01.org>, Boris Pismenny <borisp@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45796 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750761AbdFQPZp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 11:25:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Missing crypto deps for some platforms.
Default to n for new module.

config: m68k-amcore_defconfig (attached as .config)
compiler: m68k-linux-gcc (GCC) 4.9.0

make.cross ARCH=m68k
All errors (new ones prefixed by >>):

   net/built-in.o: In function `tls_set_sw_offload':
>> (.text+0x732f8): undefined reference to `crypto_alloc_aead'
   net/built-in.o: In function `tls_set_sw_offload':
>> (.text+0x7333c): undefined reference to `crypto_aead_setkey'
   net/built-in.o: In function `tls_set_sw_offload':
>> (.text+0x73354): undefined reference to `crypto_aead_setauthsize'

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Dave Watson <davejwatson@fb.com>
---
 net/tls/Kconfig | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/tls/Kconfig b/net/tls/Kconfig
index b13541f..eb58303 100644
--- a/net/tls/Kconfig
+++ b/net/tls/Kconfig
@@ -4,9 +4,12 @@
 config TLS
 	tristate "Transport Layer Security support"
 	depends on INET
-	default m
+	select CRYPTO
+	select CRYPTO_AES
+	select CRYPTO_GCM
+	default n
 	---help---
 	Enable kernel support for TLS protocol. This allows symmetric
 	encryption handling of the TLS protocol to be done in-kernel.
 
-	If unsure, say M.
+	If unsure, say N.
-- 
2.9.3
