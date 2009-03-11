From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Openssl/Openssh Offload to Linux Crypto
Date: Wed, 11 Mar 2009 11:07:50 +0800
Message-ID: <20090311030750.GA17900@gondor.apana.org.au>
References: <DB599F406D04E34389140B7D99C71B1B0747FC81@SDCEXCHANGE01.ad.amcc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-crypto@vger.kernel.org, Loc Ho <lho@amcc.com>,
	netdev@vger.kernel.org
To: Shasi Pulijala <spulijala@amcc.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <DB599F406D04E34389140B7D99C71B1B0747FC81@SDCEXCHANGE01.ad.amcc.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 10, 2009 at 07:46:34PM -0700, Shasi Pulijala wrote:
>=20
> I am trying to use OpenSSH (which uses the Openssl lib with HW Offloa=
d crypto engine support). I am using the patched version of OpenSSL tha=
t I submitted. It uses the /dev/crypto interface that was provided by t=
he patch [1] submitted to Opensource.=20
>        The interface is provided in such a way that one file descript=
or per session is opened. On this fd we set the session, do cipher/hash=
 operations and when done delete the session and close the fd. The prob=
lem arises after running this iteration (open, session set, operation a=
nd close) for several hundred times (over 500 times), the opening of fi=
le /dev/crypto fails with error -2 (no such file). I tried looking at t=
he open system call implementation and found that =E2=80=9Cinode =3D ne=
xt.dentry->d_inode=E2=80=9D is NULL in routine =E2=80=9C__link_path_wal=
k=E2=80=9D in fs/namei.c =C2=A0which is not the case when it is working=
=2E

Loc can probably give a more specific answer to your question.

But I wanted to say something about SSL offload in general.  We've
talked about this amongst the networking group and the consensus
seems to be that we should be doing the SSL data path in the kernel.

So rather than using the crypto user-space API for SSL offload, we
should really provide it as through the usual socket interface just
as we do with IPsec.

The SSL control path however should remain in user-space, even if
and when we add public key support to the kernel crypto system.
Though that could and should be made available to user-space SSL
through the crypto user-space API.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-crypto"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
