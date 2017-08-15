From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 1/2] mlx4: remove unnecessary pci_set_drvdata()
Date: Tue, 15 Aug 2017 21:00:38 +0300
Message-ID: <20170815180038.GY24282@mtr-leonro.local>
References: <1502778786-14738-1-git-send-email-yanjun.zhu@oracle.com>
 <20170815071336.GL24282@mtr-leonro.local>
 <20170815172149.GC15171@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="mYOwxzDtEZWltKxP"
Cc: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170815172149.GC15171-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--mYOwxzDtEZWltKxP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 15, 2017 at 11:21:49AM -0600, Jason Gunthorpe wrote:
> On Tue, Aug 15, 2017 at 10:13:36AM +0300, Leon Romanovsky wrote:
> > On Tue, Aug 15, 2017 at 02:33:05AM -0400, Zhu Yanjun wrote:
> > > The driver core clears the driver data to NULL after device_release
> > > or on probe failure. Thus, it is not necessary to manually clear the
> > > device driver data to NULL.
> > >
> >
> > It makes sense and I'm pretty sure that you are right, but I'm failing
> > to find the function in device core which sets it to NULL. Can you help
> > me and present the actual call stack to that code place?
>
> http://elixir.free-electrons.com/linux/v4.13-rc1/source/drivers/base/dd.c#L840
>
> The call to the remove callback is on line 833.
>
> This is done after dropping devres, so you could allocate the drv data
> inside a devm object and everything would unwind correctly.

Thanks for the pointer. Will it be called in case of failure during
initialization too?

>
> In this case, the kfree is explicit, so I would advocate for still putting
> the null near the kfree to minimize the time where a free'd pointer is
> present - eg incase a devm callback or some other bug accidently
> touches it.
>
> Jason

--mYOwxzDtEZWltKxP
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmTNsYACgkQ5GN7iDZy
WKdnrxAAsurt23xKx0/YT1u5e2CnHrX+8Ys/XaW1MRYB2WG1fvop65hD43FKERLy
dk9A+KDBDXciCfdI/xYNpiF/0m2PHc/zUSNoZNg1wTrCDl4qkpS1p0l6XPW6o8cv
f7P18cYek1L4v0cnZzfOjT4ABFi/ULM1zzj+rgdhKU054fXNRHvIVugfErvLGTUH
UiWkuZCr39MpW5i3BjtB9XUulCCS+2YYxBtdR+9lZ9PI4lQpiaOBEIV15vKw9QmZ
HW75fGwmV+i0IfAph/RaxRUFIF4yJ7WisSAgvKmuC2yHzvA0q6EnKhIc04EsrkZx
JG+PZAs/4dnU99kpS7TXvwfhkz/HmG8Pk6OnxuCsxy03PvvM6QNh4r5rYPKMX+hf
5wwQxNs8Yks3RC1ctTQODyAAoXniGhBe2/hoE+M0dMeCbt32DTTKpT0x9LFp/od6
EGnYJ3wz2JXSTIBxbJR446BJQA91XHwpZ8/pnRyScovCn5p6KwRYOsQtBeDeCEB2
JQauh4vQwiWU8j2Z/6UkHmSH3L4BXWWOOSpaE5agAOmPO7zwYGj15KHWglhi8dLe
jWr5uyWZqWtjcyJW9QQCpaUKRjZlH7SsRMCexPkqbE592v1cpr3j+nDP+KkYrKZq
cGXxrtFn8slFM5JGhwCfqETkRO4BkfwJ65OFjaaaZKtSlp0e6zo=
=SAXr
-----END PGP SIGNATURE-----

--mYOwxzDtEZWltKxP--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
