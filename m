From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm-current tree with the net-next
 tree
Date: Thu, 2 Nov 2017 18:52:49 +1100
Message-ID: <20171102185249.1938e778@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Sasha Levin <alexander.levin@verizon.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Today's linux-next merge of the akpm-current tree got a conflict in:

  include/net/inet_sock.h

between commit:

  60e2a7780793 ("tcp: TCP experimental option for SMC")

from the net-next tree and commit:

  8a3e1a11b8af ("kmemcheck: remove annotations")

from the akpm-current tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc include/net/inet_sock.h
index 2135c9ba6ac3,21c3e4d73b88..000000000000
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@@ -92,12 -90,10 +90,11 @@@ struct inet_request_sock 
  				wscale_ok  : 1,
  				ecn_ok	   : 1,
  				acked	   : 1,
 -				no_srccheck: 1;
 +				no_srccheck: 1,
 +				smc_ok	   : 1;
- 	kmemcheck_bitfield_end(flags);
  	u32                     ir_mark;
  	union {
 -		struct ip_options_rcu	*opt;
 +		struct ip_options_rcu __rcu	*ireq_opt;
  #if IS_ENABLED(CONFIG_IPV6)
  		struct {
  			struct ipv6_txoptions	*ipv6_opt;
