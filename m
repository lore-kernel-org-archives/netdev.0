From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40e: don't enable and init FCOE by default when do PF
 reset
Date: Fri, 16 Jan 2015 06:47:08 -0800
Message-ID: <1421419628.2632.112.camel@jtkirshe-mobl>
References: <933BEC2E04D6A5458F4B0239FB547F9A34CCCD35@fmsmsx118.amr.corp.intel.com>
	 <54B86DF8.3040206@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-e7Qk5SsZ95BmrnSLLZjI"
Cc: "Dev, Vasu" <vasu.dev@intel.com>,
	Ethan Zhao <ethan.kernel@gmail.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"Parikh, Neerav" <neerav.parikh@intel.com>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"brian.maly@oracle.com" <brian.maly@oracle.com>
To: ethan zhao <ethan.zhao@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54B86DF8.3040206@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-e7Qk5SsZ95BmrnSLLZjI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-01-16 at 09:48 +0800, ethan zhao wrote:
> Vasu,
>=20
>     OK, disable FCOE as default configuration as a temporary step to=20
> make it  work.

Sounds like I should expect a v2 coming, correct?

>=20
>=20
> Thanks,
> Ethan
>=20
> On 2015/1/16 7:45, Dev, Vasu wrote:
> >> -----Original Message-----
> >> From: ethan zhao [mailto:ethan.zhao@oracle.com]
> >> Sent: Tuesday, January 13, 2015 6:41 PM
> >> To: Dev, Vasu
> >> Cc: Ethan Zhao; Ronciak, John; Kirsher, Jeffrey T; Brandeburg, Jesse; =
Allan,
> >> Bruce W; Wyborny, Carolyn; Skidmore, Donald C; Rose, Gregory V; Vick,
> >> Matthew; Williams, Mitch A; Parikh, Neerav; Linux NICS; e1000-
> >> devel@lists.sourceforge.net; netdev@vger.kernel.org; linux-
> >> kernel@vger.kernel.org; brian.maly@oracle.com
> >> Subject: Re: [PATCH] i40e: don't enable and init FCOE by default when =
do PF
> >> reset
> >>
> >> Vasu,
> >>
> >> On 2015/1/14 3:38, Dev, Vasu wrote:
> >>>> -----Original Message-----
> >>>>>>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
> >>>>>>> b/drivers/net/ethernet/intel/i40e/i40e_main.c
> >>>>>>> index a5f2660..a2572cc 100644
> >>>>>>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> >>>>>>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> >>>>>>> @@ -6180,9 +6180,12 @@ static void i40e_reset_and_rebuild(struct
> >>>>>>> i40e_pf *pf, bool reinit)
> >>>>>>>       }
> >>>>>>>    #endif /* CONFIG_I40E_DCB */
> >>>>>>>    #ifdef I40E_FCOE
> >>>>>>> -   ret =3D i40e_init_pf_fcoe(pf);
> >>>>>>> -   if (ret)
> >>>>>>> -           dev_info(&pf->pdev->dev, "init_pf_fcoe failed: %d\n",=
 ret);
> >>>>>>> +   if (pf->flags & I40E_FLAG_FCOE_ENABLED) {
> >>>>>>> +           ret =3D i40e_init_pf_fcoe(pf);
> >>>>> Calling i40e_init_pf_fcoe() here conflicts with its
> >>>> I40E_FLAG_FCOE_ENABLED pre-condition since
> >> I40E_FLAG_FCOE_ENABLED is
> >>>> set by very same i40e_init_pf_fcoe(), in turn i40e_init_pf_fcoe()
> >>>> will never get called.
> >>>>
> >>>> I don't think so,  here ,i40e_reset_and_rebuild()  is not the only
> >>>> and the first place that  i40e_init_pf_fcoe() is called, see
> >>>> i40e_probe(), that is the first chance.
> >>>>
> >>>> i40e_probe()
> >>>> -->i40e_sw_init()
> >>>>        -->i40e_init_pf_fcoe()
> >>>>
> >>>> And the I40E_FLAG_FCOE_ENABLED is possible be set by
> >>>> i40e_fcoe_enable() or i40e_fcoe_disable() interface before the reset
> >>>> action is to be done.
> >>>>
> >>> It is set by i40e_init_pf_fcoe() and you are right that the modified =
call flow
> >> by your patch won't impact setting of I40E_FLAG_FCOE_ENABLED anyway
> >> which could have prevented calling i40e_init_pf_fcoe() as I described =
above,
> >> so this is not an issue with the patch.
> >>>> BTW, the reason I post this patch is that we hit a bug, after setup
> >>>> vlan, the PF is enabled to FCOE.
> >>>>
> >>> Then that BUG would still remain un-fixed and calling i40e_init_pf_fc=
oe()
> >> under I40E_FLAG_FCOE_ENABLED  flag really won't affect call flow to fi=
x
> >> anything. I mean I40E_FLAG_FCOE_ENABLED  condition will be true with "=
pf-
> >>> hw.func_caps.fcoe =3D=3D true" and otherwise calling i40e_init_pf_fco=
e() simply
> >> returns back early on after checking "pf->hw.func_caps.fcoe =3D=3D fal=
se", so
> >> how that bug is fixed here by added I40E_FLAG_FCOE_ENABLED  condition =
?
> >> What is the bug ?
> >>    The func_caps.fcoe is assigned by following call path, under our te=
st
> >> environment,
> >>
> >>    i40e_probe()
> >>     ->i40e_get_capabilities()
> >>        ->i40e_aq_discover_capabilities()
> >>           ->i40e_parse_discover_capabilities()
> >>
> >>    Or
> >>
> >>    i40e_reset_and_rebuild()
> >>     ->i40e_get_capabilities()
> >>       ->i40e_aq_discover_capabilities()
> >>         ->i40e_parse_discover_capabilities()
> >>
> >>    Under our test environment, the "pf->hw.func_caps.fcoe" is true. so=
 if
> >> i40e_reset_and_rebuild() is called for VLAN setup, ethtool diagnostic =
test.
> >>    And then i40e_init_pf_fcoe() is to be called,
> >>
> >>    While if (!pf->hw.func_caps.fcoe) wouldn't return,
> >>
> > I said it would return with "pf->hw.func_caps.fcoe =3D=3D false" in my =
last response, more details below.
> >
> >>    So  pf->flags is set to I40E_FLAG_FCOE_ENABLED.
> >>
> >>    With my patch,  i40e_init_pf_fcoe() is only called after
> >> I40E_FLAG_FCOE_ENABLED is set before reset.
> >>
> >> Enable FCOE in i40e_probe() or not is another issue.
> >>
> > Nope since both cases we should do i40e_init_pf_fcoe() or don't based o=
n fcoe cap true or false.
> >
> > I don't have much to add as I described before with the your patch that=
 "calling i40e_init_pf_fcoe() under I40E_FLAG_FCOE_ENABLED  flag really won=
't affect call flow to fix anything. I mean I40E_FLAG_FCOE_ENABLED  conditi=
on will be true with "pf->hw.func_caps.fcoe =3D=3D true" and otherwise call=
ing i40e_init_pf_fcoe() simply returns back early on after checking "pf->hw=
.func_caps.fcoe =3D=3D false".
> >
> > May be I'm missing something, I guess next either go with CONFIG_I40E_F=
COE disable as I suggested before and now it in upstream kernel or we can h=
ave further off list discussion to fix the issue you are trying to fix with=
 the patch.
> >
> > Thanks,
> > Vasu
> >
> >> Thanks,
> >> Ethan
> >>
> >>
> >>>>> Jeff Kirsher should be getting out a patch queued by me which adds
> >>>> I40E_FCoE Kbuild option, in that FCoE is disabled by default and
> >>>> user could enable FCoE only if needed, that patch would do same of
> >>>> skipping
> >>>> i40e_init_pf_fcoe() whether FCoE capability in device enabled or not
> >>>> in default config.
> >>>> The following patch will not fix the above issue -- configuration of
> >>>> PF will be changed via reset.
> >>>> How about the FCOE is configured and disabled by  i40e_fcoe_disable(=
)
> >>>> , then reset happens ?
> >>>>
> >>> May be but if the BUG is due to FCoE being enabled then having it dis=
abled
> >> in config will avoid the bug for non FCoE config option and once bug i=
s
> >> understood then that has to be fixed for FCoE enabled config also as I=
 asked
> >> above.
> >>> Thanks Ethan for detailed response.
> >>> Vasu
> >>>
> >>>>>   From patchwork Wed Oct  2 23:26:08 2013
> >>>>> Content-Type: text/plain; charset=3D"utf-8"
> >>>>> MIME-Version: 1.0
> >>>>> Content-Transfer-Encoding: 7bit
> >>>>> Subject: [net] i40e: adds FCoE configure option
> >>>>> Date: Thu, 03 Oct 2013 07:26:08 -0000
> >>>>> From: Vasu Dev <vasu.dev@intel.com>
> >>>>> X-Patchwork-Id: 11797
> >>>>>
> >>>>> Adds FCoE config option I40E_FCOE, so that FCoE can be enabled as
> >>>>> needed but otherwise have it disabled by default.
> >>>>>
> >>>>> This also eliminate multiple FCoE config checks, instead now just
> >>>>> one config check for CONFIG_I40E_FCOE.
> >>>>>
> >>>>> The I40E FCoE was added with 3.17 kernel and therefore this patch
> >>>>> shall be applied to stable 3.17 kernel also.
> >>>>>
> >>>>> CC: <stable@vger.kernel.org>
> >>>>> Signed-off-by: Vasu Dev <vasu.dev@intel.com>
> >>>>> Tested-by: Jim Young <jamesx.m.young@intel.com>
> >>>>>
> >>>>> ---
> >>>>> drivers/net/ethernet/intel/Kconfig           |   11 +++++++++++
> >>>>>    drivers/net/ethernet/intel/i40e/Makefile     |    2 +-
> >>>>>    drivers/net/ethernet/intel/i40e/i40e_osdep.h |    4 ++--
> >>>>>    3 files changed, 14 insertions(+), 3 deletions(-)
> >>>>>
> >>>>> diff --git a/drivers/net/ethernet/intel/Kconfig
> >>>>> b/drivers/net/ethernet/intel/Kconfig
> >>>>> index 5b8300a..4d61ef5 100644
> >>>>> --- a/drivers/net/ethernet/intel/Kconfig
> >>>>> +++ b/drivers/net/ethernet/intel/Kconfig
> >>>>> @@ -281,6 +281,17 @@ config I40E_DCB
> >>>>>
> >>>>>             If unsure, say N.
> >>>>>
> >>>>> +config I40E_FCOE
> >>>>> +       bool "Fibre Channel over Ethernet (FCoE)"
> >>>>> +       default n
> >>>>> +       depends on I40E && DCB && FCOE
> >>>>> +       ---help---
> >>>>> +         Say Y here if you want to use Fibre Channel over Ethernet=
 (FCoE)
> >>>>> +         in the driver. This will create new netdev for exclusive =
FCoE
> >>>>> +         use with XL710 FCoE offloads enabled.
> >>>>> +
> >>>>> +         If unsure, say N.
> >>>>> +
> >>>>>    config I40EVF
> >>>>>           tristate "Intel(R) XL710 X710 Virtual Function Ethernet s=
upport"
> >>>>>           depends on PCI_MSI
> >>>>> diff --git a/drivers/net/ethernet/intel/i40e/Makefile
> >>>>> b/drivers/net/ethernet/intel/i40e/Makefile
> >>>>> index 4b94ddb..c405819 100644
> >>>>> --- a/drivers/net/ethernet/intel/i40e/Makefile
> >>>>> +++ b/drivers/net/ethernet/intel/i40e/Makefile
> >>>>> @@ -44,4 +44,4 @@ i40e-objs :=3D i40e_main.o \
> >>>>>           i40e_virtchnl_pf.o
> >>>>>
> >>>>>    i40e-$(CONFIG_I40E_DCB) +=3D i40e_dcb.o i40e_dcb_nl.o
> >>>>> -i40e-$(CONFIG_FCOE:m=3Dy) +=3D i40e_fcoe.o
> >>>>> +i40e-$(CONFIG_I40E_FCOE) +=3D i40e_fcoe.o
> >>>>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_osdep.h
> >>>>> b/drivers/net/ethernet/intel/i40e/i40e_osdep.h
> >>>>> index 045b5c4..ad802dd 100644
> >>>>> --- a/drivers/net/ethernet/intel/i40e/i40e_osdep.h
> >>>>> +++ b/drivers/net/ethernet/intel/i40e/i40e_osdep.h
> >>>>> @@ -78,7 +78,7 @@ do {                                             =
               \
> >>>>>    } while (0)
> >>>>>
> >>>>>    typedef enum i40e_status_code i40e_status; -#if
> >>>>> defined(CONFIG_FCOE)
> >>>>> || defined(CONFIG_FCOE_MODULE)
> >>>>> +#ifdef CONFIG_I40E_FCOE
> >>>>>    #define I40E_FCOE
> >>>>> -#endif /* CONFIG_FCOE or CONFIG_FCOE_MODULE */
> >>>>> +#endif
> >>>>>    #endif /* _I40E_OSDEP_H_ */
> >>>>>
> >>>>>>> +           if (ret)
> >>>>>>> +                   dev_info(&pf->pdev->dev,
> >>>>>>> +                            "init_pf_fcoe failed: %d\n", ret);
> >>>>>>> +   }
> >>>>>>>
> >>>>>>>    #endif
> >>>>>>>       /* do basic switch setup */
> >>>>>>> --
> >>>>>>> 1.8.3.1
> >>>> Thanks,
> >>>> Ethan
>=20



--=-e7Qk5SsZ95BmrnSLLZjI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUuSRtAAoJEOVv75VaS+3OR8MP+gNV3XBxd3Pmepb/cPZ53JXe
oIAU3u0HGwFqXj4hCx67KJTRSVM3IwtmW9Ep0p4bahVQdHTqGsFss2gWUqyQqOpj
eJ1van/ZUF2ibAaN32KriaYTNEdEeDRKl9y1b/vhkq/Mvb4zrNU08hQHsxcj8DAh
x1v5INrX+nQiaUPnmMYbiYBfsn74bW7vhT+CrhT/9cNyCJDphbr8O9xt4hMENY7r
xBXnpNHDQiSbhW/rQc9+KTClCK+spc8TTxeJryAFxvP2dhR/eT7EZOIj/ls6ZV5A
X7rUNKuR7/q8PhcmNeR3GUww8/G6v0OiAkqlS3QjC2YjAnZezkYRrrzxE2EmQJrM
/8OYux/X0I73xELx5EoXrAjJHXp9GlDXsDO2GwA0buB+04tghVu9+uDlaOZIxGpe
Y/1r6KTbLsVe0Z4uHAy+Tp7cRcb4FioHg86mAAejEZUXwsVhXhaJw1xraF6NAH2w
l3lYA1+mzDefo3uCjKsxWsZJgn0MCScTzfdHbPLnzKraCCoyFOayYP9se171YAWZ
3+6yjcUwpfOsxNTqCBrPyKby+oav9eyFuR8fOwwIbkWfic/IuSlQzCOnuH78BvBZ
0NBAX3Vk82CuKCwsHkHlg2pKJu0GtnWM+SjRc57iWY13bcYzyK9OBUx7bjC74QVB
IAWijD1WUKOgAaBv6Xrv
=lMzH
-----END PGP SIGNATURE-----

--=-e7Qk5SsZ95BmrnSLLZjI--
