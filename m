From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: Bug somewhere in crypto or ipsec stuff
Date: Thu, 30 Oct 2003 12:17:32 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031030.121732.12858700.yoshfuji@linux-ipv6.org>
References: <16288.30574.745348.194005@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, davem@redhat.com,
        jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: paulus@samba.org
In-Reply-To: <16288.30574.745348.194005@cargo.ozlabs.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <16288.30574.745348.194005@cargo.ozlabs.ibm.com> (at Thu, 30 Oct 2003 13:29:02 +1100), Paul Mackerras <paulus@samba.org> says:

> I get this oops in strcmp, called from crypto_alg_lookup, when I run
> the "spi" command from a freeswan snapshot from 13 October this year.
> The kernel is 2.6.0-test9.
> 
> Oops: kernel access of bad area, sig: 11 [#1]
:
> Call trace:
>  [c00cf058] crypto_alloc_tfm+0x1c/0x104
>  [cd97fb34] ipcomp_init_state+0x90/0x118 [ipcomp]
:

> The problem is basically that crypto_alg_lookup gets called with NULL
> for the `name' parameter.

I would just disallow name == NULL,
well, what algorithm do you expect?

===== crypto/api.c 1.30 vs edited =====
--- 1.30/crypto/api.c	Sat Mar 29 20:16:58 2003
+++ edited/crypto/api.c	Thu Oct 30 12:07:43 2003
@@ -36,6 +36,9 @@
 struct crypto_alg *crypto_alg_lookup(const char *name)
 {
 	struct crypto_alg *q, *alg = NULL;
+
+	if (!name)
+		return NULL;
 	
 	down_read(&crypto_alg_sem);
 	


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
