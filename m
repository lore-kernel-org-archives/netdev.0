From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Trivial ipv6 fix.
Date: Mon, 02 Aug 2004 06:59:40 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040802.065940.86004622.yoshfuji@linux-ipv6.org>
References: <1091434328.16469.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, pekkas@netcore.fi, linux-kernel@vger.kernel.org,
        yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: suckfish@ihug.co.nz
In-Reply-To: <1091434328.16469.5.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <1091434328.16469.5.camel@localhost.localdomain> (at Mon, 02 Aug 2004 20:12:08 +1200), Ralph Loader <suckfish@ihug.co.nz> says:

> ipv6_addr_hash doesn't do what it's comment says.  The comment was
> probably what was intended, not that it'll make much difference in
> practice.

Oops, David, please apply this.

> Signed-off-by: Ralph Loader <suckfish@ihug.co.nz>
Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== include/net/addrconf.h 1.17 vs edited =====
--- 1.17/include/net/addrconf.h	2004-07-29 02:00:50 +09:00
+++ edited/include/net/addrconf.h	2004-08-02 22:57:38 +09:00
@@ -178,8 +178,8 @@
 	 * This will include the IEEE address token on links that support it.
 	 */
 
-	word = addr->s6_addr[2] ^ addr->s6_addr32[3];
-	word  ^= (word>>16);
+	word = addr->s6_addr32[2] ^ addr->s6_addr32[3];
+	word ^= (word >> 16);
 	word ^= (word >> 8);
 
 	return ((word ^ (word >> 4)) & 0x0f);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
