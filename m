From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 27 Apr 2016 12:01:13 +1000
Message-ID: <20160427120113.2ce0ab69@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/macsec.c

between commit:

  748164802c1b ("macsec: add missing macsec prefix in uapi")

from the net tree and commit:

  f60d94c00968 ("macsec: use nla_put_u64_64bit()")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/macsec.c
index c6385617bfb2,a172a1ffa151..000000000000
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@@ -2231,9 -2271,11 +2276,11 @@@ static int nla_put_secy(struct macsec_s
  	if (!secy_nest)
  		return 1;
  
- 	if (nla_put_sci(skb, MACSEC_SECY_ATTR_SCI, secy->sci) ||
- 	    nla_put_u64(skb, MACSEC_SECY_ATTR_CIPHER_SUITE,
- 			MACSEC_DEFAULT_CIPHER_ID) ||
+ 	if (nla_put_sci(skb, MACSEC_SECY_ATTR_SCI, secy->sci,
+ 			MACSEC_SECY_ATTR_PAD) ||
+ 	    nla_put_u64_64bit(skb, MACSEC_SECY_ATTR_CIPHER_SUITE,
 -			      DEFAULT_CIPHER_ID,
++			      MACSEC_DEFAULT_CIPHER_ID,
+ 			      MACSEC_SECY_ATTR_PAD) ||
  	    nla_put_u8(skb, MACSEC_SECY_ATTR_ICV_LEN, secy->icv_len) ||
  	    nla_put_u8(skb, MACSEC_SECY_ATTR_OPER, secy->operational) ||
  	    nla_put_u8(skb, MACSEC_SECY_ATTR_PROTECT, secy->protect_frames) ||
@@@ -3184,10 -3219,11 +3236,11 @@@ static int macsec_fill_info(struct sk_b
  	struct macsec_secy *secy = &macsec_priv(dev)->secy;
  	struct macsec_tx_sc *tx_sc = &secy->tx_sc;
  
- 	if (nla_put_sci(skb, IFLA_MACSEC_SCI, secy->sci) ||
+ 	if (nla_put_sci(skb, IFLA_MACSEC_SCI, secy->sci,
+ 			IFLA_MACSEC_PAD) ||
  	    nla_put_u8(skb, IFLA_MACSEC_ICV_LEN, secy->icv_len) ||
- 	    nla_put_u64(skb, IFLA_MACSEC_CIPHER_SUITE,
- 			MACSEC_DEFAULT_CIPHER_ID) ||
+ 	    nla_put_u64_64bit(skb, IFLA_MACSEC_CIPHER_SUITE,
 -			      DEFAULT_CIPHER_ID, IFLA_MACSEC_PAD) ||
++			      MACSEC_DEFAULT_CIPHER_ID, IFLA_MACSEC_PAD) ||
  	    nla_put_u8(skb, IFLA_MACSEC_ENCODING_SA, tx_sc->encoding_sa) ||
  	    nla_put_u8(skb, IFLA_MACSEC_ENCRYPT, tx_sc->encrypt) ||
  	    nla_put_u8(skb, IFLA_MACSEC_PROTECT, secy->protect_frames) ||
