From: Amos Kong <akong@redhat.com>
Subject: Re: [PATCH net-next] tun: return NET_XMIT_DROP for dropped packets
Date: Wed, 19 Nov 2014 00:53:59 +0800
Message-ID: <20141118165359.GA18636@air.redhat.com>
References: <1416288041-30921-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4Ckj6UjgE2iN1+kY"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416288041-30921-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 18, 2014 at 01:20:41PM +0800, Jason Wang wrote:
> After commit 5d097109257c03a71845729f8db6b5770c4bbedc
> ("tun: only queue packets on device"), NETDEV_TX_OK was returned for
> dropped packets. This will confuse pktgen since dropped packets were
> counted as sent ones.
>=20
> Fixing this by returning NET_XMIT_DROP to let pktgen count it as error
> packet.
>=20
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/tun.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index e3fa65a..ac53a73 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -819,7 +819,7 @@ drop:
>  	skb_tx_error(skb);
>  	kfree_skb(skb);
>  	rcu_read_unlock();
> -	return NETDEV_TX_OK;
> +	return NET_XMIT_DROP;

Quoted from linux/drivers/firewire/net.c:

  /*
   * FIXME: According to a patch from 2003-02-26, "returning non-zero
   * causes serious problems" here, allegedly.  Before that patch,
   * -ERRNO was returned which is not appropriate under Linux 2.6.
   * Perhaps more needs to be done?  Stop the queue in serious
   * conditions and restart it elsewhere?
   */

I saw many drivers return NETDEV_TX_OK in xmit for drop packets, eg: virtio=
_net.c

>  }
> =20
>  static void tun_net_mclist(struct net_device *dev)
> --=20
> 1.9.1

--=20
			Amos.

--4Ckj6UjgE2iN1+kY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUa3mnAAoJELxSv6I5vP9jNM8P/1xRnuF/aufE6HbA/VcK0X1x
AK/SIhc9b/vZ7UxU19kBHXMuvEEmyKhhQEqOYxIPIEXfaKuVBOq0rqfIIknFbQiK
V1Km99ltlk+nq2mBbadGLm/l2Y3ZiACGShlbZisWhQL1QkR8gC3OGZGfJ0I/5QWd
f4woJQD1w3K033Re6YG8WUCf0+NOXPF1VfT8emD38KktuhPIO5rpIP3kVxI/7uVJ
s/ZxFYIIs6w6vrU9gaf2NZrNPuAjjtuAPRmk6yDjaBWQvjxgMKuQ0Nw0jh47kkdm
IXYAlagvxRbbe2StduayjpuSFZbWJhfBs0ubC+nKeOV2Cr+QWSQcSTddareDWYFk
SKEUcNjdSPOOCdPut1c/4g+jbdhKhhIliZV981DOu133/wUGhH7uCMO6rqlFw24I
O6BGccl9YovTGcNbQMG+SQx6giB3zw5kLS5inmfjJHh4vlbuBSEMbfArIm7tzRwD
UDdqpla50XUT/U7SVD29hjcLNP1jtZgM7yI9qXkoQ8o1SqrWWiDd1DNnpeU1ris/
SoiNxf7jzREPIFfsVcAihc6U+HrraS9XyEY9JrHBjMRXIrcnmZ0sZwQ1csutyn1c
r9mU3y2Heh8G4wmuQYIhz15KlzAwUO7PELUpjz15IGbZIihQuUD4YovCGU+nEdgu
zSEFdXhurBLxpc9iF9zM
=MFYZ
-----END PGP SIGNATURE-----

--4Ckj6UjgE2iN1+kY--
