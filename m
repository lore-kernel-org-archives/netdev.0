From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Miscellaneous clean-ups
Date: Thu, 03 Oct 2002 10:36:17 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021003.103617.04446177.davem@redhat.com>
References: <20021004.011315.05129566.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   netfilter-devel@lists.netfilter.org, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20021004.011315.05129566.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Fri, 04 Oct 2002 01:13:15 +0900 (JST)

   @@ -1187,7 +1187,7 @@
    	ASSERT_RTNL();
    
    	memset(&addr, 0, sizeof(struct in6_addr));
   -	addr.s6_addr[15] = 1;
   +	addr.s6_addr32[3] = __constant_htonl(0x00000001);
    
Do not use __constant_htonl() in runtime code, use htonl().
Arnaldo de Melo told you this the other day for another one
of your patches, so you must fix this kind of stuff up before
I'll apply any of your patches which have this problem.

Only use __constant_htonl() for compile time initialization of data
built into the kernel.

Otherwise I like you patch, please fix it up so I may apply it.
