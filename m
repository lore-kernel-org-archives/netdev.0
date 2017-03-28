From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: stmmac: fix number of tx queues in
 stmmac_poll
Date: Tue, 28 Mar 2017 15:56:55 +0200
Message-ID: <20170328135655.GA3523@ulmo.ba.sec>
References: <20170325072621.GA20997@Red>
 <74765cbf-897a-67a1-7f42-337bf7dff6a8@synopsys.com>
 <20170327170058.GA8441@Red>
 <20170327.102831.1248194814523871799.davem@davemloft.net>
 <c8ec25cb-0369-a1b3-9f5b-dfd1ed6f9148@synopsys.com>
 <71d841cd-b07b-2635-c2cf-f7af5f5ed2c9@axis.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="5mCyUwZo2JvN/JJP"
Cc: Joao Pinto <Joao.Pinto@synopsys.com>,
        David Miller <davem@davemloft.net>, clabbe.montjoie@gmail.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34497 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755666AbdC1N6J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 09:58:09 -0400
Received: by mail-lf0-f67.google.com with SMTP id x137so10620391lff.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 06:57:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <71d841cd-b07b-2635-c2cf-f7af5f5ed2c9@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 28, 2017 at 03:34:58PM +0200, Niklas Cassel wrote:
>=20
>=20
> On 03/27/2017 07:44 PM, Joao Pinto wrote:
> > =C3=80s 6:28 PM de 3/27/2017, David Miller escreveu:
> >> From: Corentin Labbe <clabbe.montjoie@gmail.com>
> >> Date: Mon, 27 Mar 2017 19:00:58 +0200
> >>
> >>> On Mon, Mar 27, 2017 at 04:26:48PM +0100, Joao Pinto wrote:
> >>>> Hi David,
> >>>>
> >>>> =C3=80s 7:26 AM de 3/25/2017, Corentin Labbe escreveu:
> >>>>> On Fri, Mar 24, 2017 at 05:16:45PM +0000, Joao Pinto wrote:
> >>>>>> For cores that have more than 1 TX queue configured, the kernel wo=
uld crash,
> >>>>>> since only one TX queue is permitted by default.
> >>>>>>
> >>>>>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> >>>>>> ---
> >>>>>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
> >>>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>>>>>
> >>>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/d=
rivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >>>>>> index 3827952..1eab084 100644
> >>>>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >>>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >>>>>> @@ -3429,7 +3429,7 @@ static int stmmac_poll(struct napi_struct *n=
api, int budget)
> >>>>>>  	struct stmmac_rx_queue *rx_q =3D
> >>>>>>  		container_of(napi, struct stmmac_rx_queue, napi);
> >>>>>>  	struct stmmac_priv *priv =3D rx_q->priv_data;
> >>>>>> -	u32 tx_count =3D priv->dma_cap.number_tx_queues;
> >>>>>> +	u32 tx_count =3D priv->plat->tx_queues_to_use;
> >>>>>>  	u32 chan =3D rx_q->queue_index;
> >>>>>>  	u32 work_done =3D 0;
> >>>>>>  	u32 queue =3D 0;
> >>>>>> --=20
> >>>>>> 2.9.3
> >>>>>>
> >>>>>
> >>>>> This patch fix the performance issue on dwmac-sun8i only.
> >>>>> The dwmac-sunxi is still broken.
> >>>>>
> >>>>
> >>>> This patch series can be upstreamed please, since they make 2 fixes,=
 one of them
> >>>> solving the problem in dwmac-sun8i.
> >>>>
> >>>> Thanks.
> >>>
> >>> As I said in a previous answer, finaly dwmac-sun8i is still broken.
> >>> Adding thoses 2 patch will just made the revert harder.
> >>
> >> I agree.
> >=20
> > For what I am understanding, SoCs base on Core versions >=3D 4.00 are w=
orking
> > properly and for some reason SoCs based on older versions are not worki=
ng.
> >=20
> > This fix is necessary, since if you have a diferent configured tx_queue=
s_to_use
> > in the driver and priv->dma_cap.number_tx_queues in the core, this can =
lead to
> > kernel crashes.
> >=20
> > The other fix (netdev resources release) is also necessary, since when =
you
> > release the driver its crashes, because the rx queue struct is freed be=
fore
> > releasing the netdevs.
> >=20
> > We can revert, but I think it might not solve the issue. We can break t=
he
> > "multiple buffers" patch into "rx multilple buffers" and "tx multiple b=
uffers",
> > but will that actually work? We can give it a try, I don't mind making =
a new
> > multiple buffers patch broken into 2, that can be tested by new cores a=
nd older
> > cores.
>=20
> I've hit a bug on stmmac where RX is broken after boot.
> Sometimes it works, and sometimes it doesn't.
> I usually notice that DHCP never receives an offer,
> but it's possible to reproduce the problem without DHCP,
> where a simple ping will not work after setting an address manually.
>=20
> I've bisected it to commit aff3d9eff843 ("net: stmmac: enable multiple bu=
ffers").
> (Note that I had to cherry-pick 22446ad8e118 ("net: stmmac: Restore DT ba=
ckwards-compatibility")
> to avoid TX queue timeouts, and the patch included in the beginning of th=
is
> mail thread "net: stmmac: fix number of tx queues in stmmac_poll" to avoid
> random crashes in stmmac_tx_clean.
>=20
> Looking at wireshark I can see that we send out a DHCP discover,
> so TX seems to be working.
> A DHCP offer is sent out from the server, but it is never received.
>=20
> Our setup has 1 RX queue and 2 TX queues.
> According to the databook, the field Receive Queue Size in register
> MTL_RxQ0_Operation_Mode is read-only when number of RX queues =3D=3D 1,
> so I guess the problem is not related to RX queue size.
> It's quite annoying since it does not trigger every single boot.
>=20
> Has anyone else noticed broken RX after boot since commit aff3d9eff843 an=
d newer?

Yeah, I've been hitting the same, or at least very similar, issue. I'm
going to attach my local stack of three patches, of which the first is
only cleanup, the second is the same as the one that Joao had sent out
earlier and patch three seems to be the one that gets things back on
track for me. I haven't quite figured out why yet, but it'd be
interesting to see if it fixes things for others.

Thierry

--5mCyUwZo2JvN/JJP
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljaa6IACgkQ3SOs138+
s6GPGBAAjG3j82S2WWjt+4Re7ngEvqLRuNh4YWmR0trjlZBS1xYELVWw4FgM5Wce
0JhBcQgUoZBcydLQUAvjfP6kaXzJejY8Mfux6cT1OtEFM6wsXeaFii6haKS2Oakb
fOAwCbd2d1YTaLLYpJ7+7d+XsFpBmttWZqO7VLsMRkA8Z/YD8w8p18eYC18/tvMl
Emj7TfgiP5uvRFBFCNYYTFYppZaae+jkoeLCMYy2tKKVg3aiwkzk+FV3ZJI0aHm0
1iqEfSJtTEZ0fhWl6JxHAY3Mj2ukSFbGSRa1zwIsu1ULL2O3E1mPJzZWJJ3Y9Dkv
ZZTBfFEcs6VTHEayTzm5e3m6PHsp8t14AJAU263/KxUE8WGD9aUy8AYoAT2prteH
xjcnwkWL+ejmKGt9WxEqJJ7UuPsC5cwghlZqxFpgAfcPL7r5AkoigQgi2TE0nUGi
iPe2HFk0vaFBD7YW26rcnsAGMz9LoWynZkfIMI4au0YtwwcSANlyu39NktPBUZWs
tSWF6VRoirAnA+a9IizOTC67zYxjFMIqi6Xc5hqQg/iEpWi6xXpylvXZXCnWzVf1
Mi8DTcIKi9VJGaGQ5t6tVP6WmTdy4Suoit90NaGkJk7CoS8pK4oMEPIntzB4qA+1
FQyapcWki6VD2luQ4AJFqRzWBejWM0lLq8FtnNGwj63PNNotVrM=
=v9pF
-----END PGP SIGNATURE-----

--5mCyUwZo2JvN/JJP--
