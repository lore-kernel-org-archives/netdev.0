From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH rdma-next V2 25/27] RDMA/netlink: Export LID mask counter
 (LMC)
Date: Mon, 17 Jul 2017 21:32:58 +0300
Message-ID: <20170717183258.GI3259@mtr-leonro.local>
References: <20170703062830.30361-1-leon@kernel.org>
 <20170703062830.30361-26-leon@kernel.org>
 <04e53968-c2e9-17b0-c51e-80a038e23711@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="uQr8t48UFsdbeI+V"
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>
To: Dennis Dalessandro <dennis.dalessandro@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:42422 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751301AbdGQSdC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Jul 2017 14:33:02 -0400
Content-Disposition: inline
In-Reply-To: <04e53968-c2e9-17b0-c51e-80a038e23711@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--uQr8t48UFsdbeI+V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 17, 2017 at 11:14:28AM -0400, Dennis Dalessandro wrote:
> On 7/3/2017 2:28 AM, Leon Romanovsky wrote:
> > From: Leon Romanovsky <leonro@mellanox.com>
> >
> > Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
> > ---
> >   drivers/infiniband/core/nldev.c  | 3 +++
> >   include/uapi/rdma/rdma_netlink.h | 5 +++++
> >   2 files changed, 8 insertions(+)
> >
> > diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/=
nldev.c
> > index ce733bf33ed9..f968a40ef5d3 100644
> > --- a/drivers/infiniband/core/nldev.c
> > +++ b/drivers/infiniband/core/nldev.c
> > @@ -47,6 +47,7 @@ static const struct nla_policy nldev_policy[RDMA_NLDE=
V_ATTR_MAX] =3D {
> >   	[RDMA_NLDEV_ATTR_SUBNET_PREFIX]	=3D { .type =3D NLA_U64 },
> >   	[RDMA_NLDEV_ATTR_LID]		=3D { .type =3D NLA_U32 },
> >   	[RDMA_NLDEV_ATTR_SM_LID]	=3D { .type =3D NLA_U32 },
> > +	[RDMA_NLDEV_ATTR_LMC]		=3D { .type =3D NLA_U8 },
> >   };
> >   static int fill_dev_info(struct sk_buff *msg, struct ib_device *devic=
e)
> > @@ -109,6 +110,8 @@ static int fill_port_info(struct sk_buff *msg,
> >   			return -EMSGSIZE;
> >   		if (nla_put_u32(msg, RDMA_NLDEV_ATTR_SM_LID, attr.sm_lid))
> >   			return -EMSGSIZE;
> > +		if (nla_put_u8(msg, RDMA_NLDEV_ATTR_LMC, attr.lmc))
> > +			return -EMSGSIZE;
> >   	}
> >   	return 0;
> >   }
> > diff --git a/include/uapi/rdma/rdma_netlink.h b/include/uapi/rdma/rdma_=
netlink.h
> > index 82e0d64346e1..d4b862e8ed15 100644
> > --- a/include/uapi/rdma/rdma_netlink.h
> > +++ b/include/uapi/rdma/rdma_netlink.h
> > @@ -292,6 +292,11 @@ enum rdma_nldev_attr {
> >   	RDMA_NLDEV_ATTR_LID,			/* u32 */
> >   	RDMA_NLDEV_ATTR_SM_LID,			/* u32 */
> > +	/*
> > +	 * LID mask count (LMC)
> > +	 */
> > +	RDMA_NLDEV_ATTR_LMC,			/* u8 */
> > +
> >   	RDMA_NLDEV_ATTR_MAX
> >   };
> >   #endif /* _UAPI_RDMA_NETLINK_H */
> >
>
> LMC =3D "Counter" or "Control"? I always thought it was the latter.

You are right, it is control.
=46rom spec:
LID Mask Control - A per-port value assigned by the Subnet Manager. The val=
ue of the LMC
specifies the number of Path Bits in the Local Identifier.

I don't know why I called it "counter".

It is wrong comment and not something else, so I'll wait till Doug's branch=
es will be ready and send fix after that.

Thanks

>
> -Denny

--uQr8t48UFsdbeI+V
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlltAtkACgkQ5GN7iDZy
WKd9SQ//W/J0OEN1ywDHjI+Ep7DenfP/GZHK9tPmdrNaXnZmc/isPezFhdHADbK8
9Y3FYySNsycL8fhnVt9Hmyi0qdVJHFWQcdArMrzFCm3XF+zAOOp4Ne+wsWvdcj0d
4cCZkmZ6Z/B2CK2zFWbMexssXxAJDMaUJXzDkFlIc94r8OW+kJZhXQtR2gUV2TaK
XaHVY0vP7tS+64J1Ui8jdoBMGQ3ng1BSKIYihHwkBnFMTCrhj0XEsf4grsDJDyKZ
YDNtMYzutWIwJaRgS3jOxqq6A2VwE6F42zfhw36FynInzINISnuJTvzIRdDUI+n4
qsCv6yxmcJ0VE2NZzDM2ROgbK7vcNwrvFBnUkvlZHq9jMMEXhMwph7eM78NsRbxF
IYZxzK/oVOlm1G8qUYWRbfzAUZgbzNJin282HT3KK9cBRZSMWR325IZlFIN4gWDh
ZD7PPgSEkR1uFDS7B30VZhiDhd1XXaKPRujuQSuOLVMK6LseNdTG7iiarEGQzU0C
jyhT5PB/n4OZHMrCRIqH9h+PaI7avI1mKnmUR1n1/wp8zdWuT599/ynt4qjsFTHP
rXggZP/qCyU854NPLiOP4r1pjLTxj4I2DH6tQ+RIT2tSUZDi/Rnng755rw+rOWVl
TUO3RdnD6C0OQPRjWgPjPyiNono6mx+HixW92ZRWC587Jc4VQVI=
=nK4U
-----END PGP SIGNATURE-----

--uQr8t48UFsdbeI+V--
