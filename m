From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET] Allow MD5 to be a module
Date: Thu, 29 Jul 2004 21:40:52 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040729114052.GA16001@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gKMricLos+KVdGMg"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

I found that recent 2.6 kernels no longer allowed me to build MD5 as
a module even though everything that used it were modules (including
ipv6 and sctp).  It turns out that there were boolean options
selecting MD5 in the Kconfig files.  Due to limitations in the current
kconfig implementation, this forces MD5 to be a boolean as well.

The usual workaround in these cases is to move the selection up
to the closest tristate.  This is what the following patch does.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=md5-module-patch

===== net/ipv6/Kconfig 1.8 vs edited =====
--- 1.8/net/ipv6/Kconfig	2003-08-09 19:14:55 +10:00
+++ edited/net/ipv6/Kconfig	2004-07-29 21:37:54 +10:00
@@ -4,8 +4,6 @@
 config IPV6_PRIVACY
 	bool "IPv6: Privacy Extensions (RFC 3041) support"
 	depends on IPV6
-	select CRYPTO
-	select CRYPTO_MD5
 	---help---
 	  Privacy Extensions for Stateless Address Autoconfiguration in IPv6
 	  support.  With this option, additional periodically-alter 
===== net/sctp/Kconfig 1.12 vs edited =====
--- 1.12/net/sctp/Kconfig	2004-03-24 05:58:14 +11:00
+++ edited/net/sctp/Kconfig	2004-07-29 21:38:32 +10:00
@@ -8,6 +8,10 @@
 config IP_SCTP
 	tristate "The SCTP Protocol (EXPERIMENTAL)"
 	depends on IPV6 || IPV6=n
+	select CRYPTO if SCTP_HMAC_SHA1 || SCTP_HMAC_MD5
+	select CRYPTO_HMAC if SCTP_HMAC_SHA1 || SCTP_HMAC_MD5
+	select CRYPTO_SHA1 if SCTP_HMAC_SHA1
+	select CRYPTO_MD5 if SCTP_HMAC_MD5
 	---help---
 	  Stream Control Transmission Protocol
 
@@ -71,18 +75,12 @@
 
 config SCTP_HMAC_SHA1
 	bool "HMAC-SHA1"
-	select CRYPTO
-	select CRYPTO_HMAC
-	select CRYPTO_SHA1
 	help 
 	  Enable the use of HMAC-SHA1 during association establishment.  It 
 	  is advised to use either HMAC-MD5 or HMAC-SHA1.
 
 config SCTP_HMAC_MD5
 	bool "HMAC-MD5"
-	select CRYPTO
-	select CRYPTO_HMAC
-	select CRYPTO_MD5
 	help
 	  Enable the use of HMAC-MD5 during association establishment.  It is 
 	  advised to use either HMAC-MD5 or HMAC-SHA1.
===== net/Kconfig 1.34 vs edited =====
--- 1.34/net/Kconfig	2004-04-06 08:22:50 +10:00
+++ edited/net/Kconfig	2004-07-29 21:37:54 +10:00
@@ -109,6 +109,8 @@
 config IPV6
 	tristate "The IPv6 protocol (EXPERIMENTAL)"
 	depends on INET && EXPERIMENTAL
+	select CRYPTO if IPV6_PRIVACY
+	select CRYPTO_MD5 if IPV6_PRIVACY
 	---help---
 	  This is experimental support for the IP version 6 (formerly called
 	  IPng "IP next generation").  You will still be able to do

--gKMricLos+KVdGMg--
