From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/8] net: Generic Receive Offload
Date: Fri, 12 Dec 2008 16:31:16 +1100
Message-ID: <20081212053116.GA2927@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58994 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751075AbYLLFbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 00:31:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

This patch series introduces the Generic Receive Offload system.  Just
as GSO generalised TSO, GRO does the same thing for LRO.  Most of the
technical details are pulled straight out of LRO, although there is no
code shared between them.

For the moment, GRO is actually more stringent than LRO, meaning that
the set of packets that it merges is strictless less than LRO.  However,
I don't anticipate this to be a huge issue as testing shows that most
packets that are worth merging will still qualify under GRO.

The reason GRO strengthened the conditions for merging is to allow the
packets to be refragmented on output.  This is what stopped us from
allowing LRO to be used on routers and bridges.  This is also essential
for LRO to be deployed on a virtual host using bridging.

In future we may extend GRO to be less strict.  In order to do so it
would be necessary for the network to be able to handle super-packets
that are different from our existing GSO packets.  Such super-packets
would retain their individual headers which would be examined and/or
modified where necessary.

As it stands GRO should be a complete no-op unless the user enables
GRO using ethtool (and someone modifies the driver involved to call
napi_gro_receive).  Once we're comfortable with GRO we could enable
it automatically whenever RX checksum offload is available.

If this series is accepted, the next step would be to convert all
the relevant drivers to call napi_gro_receive (note that ironically
drivers using netif_rx won't need to be modified to use GRO, though
they won't actually merge anything unless they support RX checksum
offload).  I've converted e1000e as an example (also because that's
the only piece of hardware I've got access to right now :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
