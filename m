From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: netlink: Add missing goto statement to netlink_insert
Date: Tue, 8 Dec 2015 14:13:19 +0800
Message-ID: <20151208061319.GA16209@gondor.apana.org.au>
References: <564E2852.8000200@profihost.ag>
 <56530A42.6030609@profihost.ag>
 <1448283451.4019628.447573353.3659E447@webmail.messagingengine.com>
 <565EBDC1.1090808@profihost.ag>
 <8737vlt6xb.fsf@stressinduktion.org>
 <5661DAC4.8040909@profihost.ag>
 <20151205010819.GA21889@gondor.apana.org.au>
 <5664A102.2030602@profihost.ag>
 <20151207012042.GA7420@gondor.apana.org.au>
 <56652E11.4010604@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Weimer <fweimer@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	jannik Winkel <j.winkel@profihost.ag>,
	Marco Schinkel <m.schinkel@profihost.ag>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56652E11.4010604@profihost.ag>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 07, 2015 at 07:58:25AM +0100, Stefan Priebe - Profihost AG wrote:
>
> Thanks, good. Can you help me to get this fix upstream into the stable
> lines?

Sure.  Greg, please apply this patch to fix up the backport for 4.1.

---8<---
The backport of 1f770c0a09da855a2b51af6d19de97fb955eca85 ("netlink:
Fix autobind race condition that leads to zero port ID") missed a
goto statement, which causes netlink to break subtly.

This was discovered by Stefan Priebe <s.priebe@profihost.ag>.

Fixes: 4e2776241766 ("netlink: Fix autobind race condition that...")
Reported-by: Stefan Priebe <s.priebe@profihost.ag>
Reported-by: Philipp Hahn <pmhahn@pmhahn.de>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index d139c43..0d6038c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1118,6 +1118,7 @@ static int netlink_insert(struct sock *sk, u32 portid)
 		if (err == -EEXIST)
 			err = -EADDRINUSE;
 		sock_put(sk);
+		goto err;
 	}
 
 	/* We need to ensure that the socket is hashed and visible. */

-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
