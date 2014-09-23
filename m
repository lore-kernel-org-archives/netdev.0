From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Wed, 24 Sep 2014 07:23:06 +1000
Message-ID: <20140924072306.799005a3@canb.auug.org.au>
References: <20140918103200.12b79941@canb.auug.org.au>
	<541A28BA.1060201@infradead.org>
	<54218AEF.5090200@suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/x+7U=C77oZhA+lZGe=v+zy0"; protocol="application/pgp-signature"
Cc: Randy Dunlap <rdunlap@infradead.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-kbuild <linux-kbuild@vger.kernel.org>,
	Linus <torvalds@linux-foundation.org>
To: Michal Marek <mmarek@suse.cz>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <54218AEF.5090200@suse.cz>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/x+7U=C77oZhA+lZGe=v+zy0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Tue, 23 Sep 2014 16:59:59 +0200 Michal Marek <mmarek@suse.cz> wrote:
>
> On 2014-09-18 02:35, Randy Dunlap wrote:
> > On 09/17/14 17:32, Stephen Rothwell wrote:
> >> Hi all,
> >>
> >> After merging the net tree, today's linux-next build (powerpc
> >> ppc64_defconfig) produced these warnings:
> >>
> >> warning: (PPC_CELL_NATIVE && BLUESTONE && CANYONLANDS && GLACIER && EI=
GER && 440EPX && 440GRX && 440GX && 460SX && 405EX) selects IBM_EMAC_RGMII =
which has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_I=
BM)
> >> warning: (PPC_CELL_NATIVE && CANYONLANDS && GLACIER && 440EP && 440EPX=
 && 440GRX && 440GP && 440GX && 460SX && 405GP) selects IBM_EMAC_ZMII which=
 has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
> >> warning: (PPC_CELL_NATIVE && 440GX && 460EX && 460SX && APM821xx) sele=
cts IBM_EMAC_TAH which has unmet direct dependencies (NETDEVICES && ETHERNE=
T && NET_VENDOR_IBM)
> >> warning: (PPC_CELL_NATIVE && AKEBONO && 440EPX && 440GRX && 440GX && 4=
40SPe && 460EX && 460SX && APM821xx && 405EX) selects IBM_EMAC_EMAC4 which =
has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
> >> warning: (PPC_CELL_NATIVE && CANYONLANDS && GLACIER && 440EP && 440EPX=
 && 440GRX && 440GP && 440GX && 460SX && 405GP) selects IBM_EMAC_ZMII which=
 has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
> >> warning: (PPC_CELL_NATIVE && BLUESTONE && CANYONLANDS && GLACIER && EI=
GER && 440EPX && 440GRX && 440GX && 460SX && 405EX) selects IBM_EMAC_RGMII =
which has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_I=
BM)
> >> warning: (PPC_CELL_NATIVE && 440GX && 460EX && 460SX && APM821xx) sele=
cts IBM_EMAC_TAH which has unmet direct dependencies (NETDEVICES && ETHERNE=
T && NET_VENDOR_IBM)
> >> warning: (PPC_CELL_NATIVE && AKEBONO && 440EPX && 440GRX && 440GX && 4=
40SPe && 460EX && 460SX && APM821xx && 405EX) selects IBM_EMAC_EMAC4 which =
has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
> >>
> >=20
> > I have looked into these and don't see why there is a problem.
> > Any help would be appreciated.
>=20
> This is a side effect of 5d6be6a5 ("scsi_netlink : Make SCSI_NETLINK
> dependent on NET instead of selecting NET"). Previously, SCSI_FC_ATTRS
> would select SCSI_NETLINK which would select CONFIG_NET. The above
> warnings are just a tip of the iceberg, the more serious issue is that
> ppc64_defconfig is lacking networking support. This is the downside of
> savedefconfig, because the 'select' implications can disappear over
> time. Looks like more defconfigs are affected by this:

And since 5d6be6a5 is now in Linus' tree, we need Michal's 5 patches
(at least) to be sent to Linus ASAP ...

So it appears that using select can get us into the same sort of
trouble that not including all needed header files can.  Unfortunately,
savedconfig makes that much worse :-(.  So anyone changing a "select X"
to "depends on X" needs to regenerate a lot of defconfigs to make sure
that there are no unforeseen consequences.

Dave, this is a bit slack of you since I reported that problem a week
ago in the net tree and yet it has not been completely fixed before you
asked Linus to pull your tree :-(

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/x+7U=C77oZhA+lZGe=v+zy0
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUIeTAAAoJEMDTa8Ir7ZwVOu4P+wXRxDZ/GYBVAP9wxgQ5MGnK
gMUcQmBXeGyMOaoJeuwDrRtU+UxFtpaN4L1YQ1G03kx8YiatkKTq+k9c8TrH3tQE
ALnts6uHpwlQGEEOvHDEJaqW53fWbC+8teSVd/ara0Cre2f0cU1zOMbwUpIKn+sS
8zu6VrgynyVKxlMfBGglD3ffpRay2FDq9mv+ezbDDd6GMZAVhSe3BBQ1YQxfeXQJ
cjhHa3U09YHJHOd7J9oBxOshaJWcA3ge8H0nTxhWq+5jfkxEwket6GaQVEgo3kIp
tDaW3cXWNnnQLnlF72UZK8aY3IfQDiBbj3flFPRFdIPTYmXBuoBw7mOXW3W6e5MH
cGZvzArhLOpyoGXpcj6UJVph2ruUk6Ww354k8eEAmbWQxwHXYNWPjVQ0gwra/om6
4xPr4VxJKzsAa1ikNqnn+4KlTnMJpbXZZkFEn0TBARqL6N+izmhmr3tiok2l86Nl
42GRvhptDE+8Kxa+DNKuosdQL5V+w+eNlqqP6xe8zOHbwvUw3ORl15c59PC9oYp5
fgYn/JbkBYA8F15ujUWDmTYcvSmhBWSZk0FA73DDjUQuRTNac+IdRb6y0YkdQsu4
pqzlGIRnlmPuACKqIOuF63K4aWxh5+fEeLElqOm/3w+0aJ0NsYHFmtpBEOnmfCXF
87zXLtCjTX85ToghPdu6
=7u6p
-----END PGP SIGNATURE-----

--Sig_/x+7U=C77oZhA+lZGe=v+zy0--
