From: MIYAZAWA Kazunori <kazunori@miyazawa.org>
Subject: [PATCH][IPsec] fix process of error from crypto module
Date: Wed, 26 Jan 2005 19:10:20 +0900
Message-ID: <200501261910.20867.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

This patch fixes the process under the case that the crypto module
returns error because of its weak keys or etc.


diff -ur a/net/ipv4/esp4.c b/net/ipv4/esp4.c
--- a/net/ipv4/esp4.c 2004-12-25 06:34:58.000000000 +0900
+++ b/net/ipv4/esp4.c 2005-01-26 18:57:18.000000000 +0900
@@ -427,7 +427,8 @@
    goto error;
   get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
  }
- crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len);
+ if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len))
+  goto error;
  x->props.header_len = sizeof(struct ip_esp_hdr) + esp->conf.ivlen;
  if (x->props.mode)
   x->props.header_len += sizeof(struct iphdr);
diff -ur a/net/ipv6/esp6.c b/net/ipv6/esp6.c
--- a/net/ipv6/esp6.c 2004-12-25 06:35:01.000000000 +0900
+++ b/net/ipv6/esp6.c 2005-01-26 18:57:04.000000000 +0900
@@ -364,7 +364,8 @@
    goto error;
   get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
  }
- crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len);
+ if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len))
+  goto error;
  x->props.header_len = sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen;
  if (x->props.mode)
   x->props.header_len += sizeof(struct ipv6hdr);


--
Kazunori Miyazawa
