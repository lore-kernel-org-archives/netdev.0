From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] sfc: add support for skb->xmit_more
Date: Wed, 22 Oct 2014 09:58:43 +0100
Message-ID: <1413968323.5994.6.camel@decadent.org.uk>
References: <1413219585-15854-1-git-send-email-dborkman@redhat.com>
	 <543C13AE.80606@solarflare.com> <543C2588.6060604@redhat.com>
	 <alpine.LFD.2.03.1410141933500.26972@solarflare.com>
	 <543FF408.3000808@solarflare.com>
	 <alpine.LFD.2.03.1410171512070.3218@solarflare.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-o5sLez8TRykI3WUAXOSY"
Cc: Robert Stonehouse <rstonehouse@solarflare.com>,
	Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	nikolay@redhat.com, netdev@vger.kernel.org,
	Shradha Shah <sshah@solarflare.com>,
	Jon Cooper <jcooper@solarflare.com>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:47929 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753065AbaJVI7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 04:59:08 -0400
In-Reply-To: <alpine.LFD.2.03.1410171512070.3218@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-o5sLez8TRykI3WUAXOSY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-10-17 at 15:32 +0100, Edward Cree wrote:
[...]
> @@ -351,7 +343,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_q=
ueue, struct sk_buff *skb)
>  	unsigned short dma_flags;
>  	int i =3D 0;
> =20
> -	EFX_BUG_ON_PARANOID(tx_queue->write_count !=3D tx_queue->insert_count);
> +	EFX_BUG_ON_PARANOID(tx_queue->write_count > tx_queue->insert_count);
[...]

Doesn't this break after 2^32 descriptors?  It seems like you would need
a similar comparison to time_after(); possibly:

	EFX_BUG_ON_PARANOID((int)(tx_queue->write_count - tx_queue->insert_count) =
> 0);

Ben.

--=20
Ben Hutchings
For every action, there is an equal and opposite criticism. - Harrison

--=-o5sLez8TRykI3WUAXOSY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVEdxyOe/yOyVhhEJAQq6yhAAmcF/XYpfps17EoPIlLUItQBHZmW0owKa
cwabqNNXH6+QEoor9RYfRrOjiQCUNT4mvNu9vIlIH13B2c4Alktc43a9BX9MyTHC
XtrFyjVkEze7c0miOF6LPhjoMsg91Qh+7InNrYuQRzg2zaiLvreN+KOBs4FRNc/i
ZICUG8gKtL4O/g3m+RIkmYxE8XCLdUwnlG6ciE9DlArh4bEvxjgNDK72rb0y5UsY
D+1EPGX7z8rpeahfqUIHjVn9lIunvuWqLKKvj91T83L3NJJ4TOcbq94H5lN8alUh
5bzjP83Y1o3+X3GsGkO62Ih28sSUGPcGbwYDcJLDvnO6rijqHWlqtHb0xW2vJ0qe
ogYxTKEy0z+80biagzstCCuNY/OWL78PSkOnFbODAeIduWTuG5EC3qYWi0y3JQUI
kof9Cwhs2qaqvmy7VEm1ZkyuzV90gNSrEiL/+OLq1zWfgYWuQ/IHOU0mNVdxGqMH
8CyGIEwrxupm5zXzoggEDD+Z9+6Md2RCTCjgLQ6BvLM1gdDtKH6yLPv/NMYyUvND
R8EgNDt16g65Bct/Iyca8mJc1uwbuWemSZeBwO7xDMe94rOTac8lrLU9FflFPop3
24VqUqeKCtwkUOCHG8fisy7PDVno4PC3p0J5OPrXXo8MkbxEG3b2f6mJBXX/8Fh3
cNljV0f9O+8=
=9r/d
-----END PGP SIGNATURE-----

--=-o5sLez8TRykI3WUAXOSY--
