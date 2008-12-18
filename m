From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Thu, 18 Dec 2008 22:07:15 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812181002380.10269@wrl-59.cs.helsinki.fi>
References: <20081217114138.GA20976@gondor.apana.org.au>
 <20081217125505.GA8379@ms2.inr.ac.ru> <20081217221637.GA27811@gondor.apana.org.au>
 <20081217.151713.90960645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1641218415-1229630835=:12061"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, ptesarik@suse.cz,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45395 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbYLRUHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 15:07:17 -0500
In-Reply-To: <20081217.151713.90960645.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1641218415-1229630835=:12061
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 17 Dec 2008, David Miller wrote:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 18 Dec 2008 09:16:37 +1100
> 
> And it also shows that our strange scheme, where we don't
> signal URG until it's within the 16-bit sequence offset
> limit, at least reports an accurate URG value.

[...snip...]

> Given all of this I still think our current compromise is likely the
> best one.  We never will advertise an URG pointer that is not pointing
> to where the URG data will be in the sequence space.

Wholeheartedly agreed, but with added note that if somebody is fool enough 
to come up complaining about the behavior we've selected (among the palette 
of broken ways we had available) we might actually succeed in convincing 
him to come up with something that has more change in working than urg 
altogether. Sadly, urg is ABI-in-stone that must everyone must keep 
supporting in some crippled-form. ...But no worries, I've a solution below 
which should satisfy everybody... :-)


-- 
 i.


[PATCH] tcp: fix all urg troubles for now

Return to stone age with 64k is enough for everybody attitude
(or was it 640k, I keep forgetting). Urg certainly works fine
if no window scaling is not allowed ;-)

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 99b7ecb..54fe815 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -72,7 +72,7 @@
 #include <net/netdma.h>
 
 int sysctl_tcp_timestamps __read_mostly = 1;
-int sysctl_tcp_window_scaling __read_mostly = 1;
+int sysctl_tcp_window_scaling __read_mostly = 0;
 int sysctl_tcp_sack __read_mostly = 1;
 int sysctl_tcp_fack __read_mostly = 1;
 int sysctl_tcp_reordering __read_mostly = TCP_FASTRETRANS_THRESH;
-- 
1.5.2.2

---696208474-1641218415-1229630835=:12061--
