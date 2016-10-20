From: "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>
Subject: RE: [PATCH net-next V2 1/9] liquidio CN23XX: HW config for VF support
Date: Thu, 20 Oct 2016 23:08:56 +0000
Message-ID: <DM3PR07MB2138EB65A7FEDBFF3746915B81D50@DM3PR07MB2138.namprd07.prod.outlook.com>
References: <1476942046-18789-2-git-send-email-rvatsavayi@caviumnetworks.com>
        <20161020.141304.286994718471308700.davem@davemloft.net>
        <DM3PR07MB21387F2B6D44558DBC36649881D50@DM3PR07MB2138.namprd07.prod.outlook.com>
 <20161020.165720.1537348879596195765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>,
        "Burla, Satananda" <Satananda.Burla@cavium.com>,
        "Manlunas, Felix" <Felix.Manlunas@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0041.outbound.protection.outlook.com ([104.47.32.41]:61886
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755249AbcJTXYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 19:24:16 -0400
In-Reply-To: <20161020.165720.1537348879596195765.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, October 20, 2016 1:57 PM
> To: Vatsavayi, Raghu
> Cc: netdev@vger.kernel.org; Chickles, Derek; Burla, Satananda; Manlunas,
> Felix
> Subject: Re: [PATCH net-next V2 1/9] liquidio CN23XX: HW config for VF
> support
>=20
> From: "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>
> Date: Thu, 20 Oct 2016 20:01:37 +0000
>=20
> >
> >
> >> -----Original Message-----
> >> From: David Miller [mailto:davem@davemloft.net]
> >> Sent: Thursday, October 20, 2016 11:13 AM
> >> To: Vatsavayi, Raghu
> >> Cc: netdev@vger.kernel.org; Vatsavayi, Raghu; Chickles, Derek; Burla,
> >> Satananda; Manlunas, Felix
> >> Subject: Re: [PATCH net-next V2 1/9] liquidio CN23XX: HW config for
> >> VF support
> >>
> >> From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
> >> Date: Wed, 19 Oct 2016 22:40:38 -0700
> >>
> >> > +/* Default behaviour of Liquidio is to provide one queue per VF.
> >> > +But Liquidio
> >> > + * can also provide multiple queues to each VF. If user wants to
> >> > +change the
> >> > + * default behaviour HW should be provided configuration info at
> >> > +init time,
> >> > + * based on which it will create control queues for communicating
> >> > +with
> >> FW.
> >> > + */
> >> > +static u32 max_vfs[2] =3D { 0, 0 };
> >> > +module_param_array(max_vfs, int, NULL, 0444);
> >> > +MODULE_PARM_DESC(max_vfs, "Assign two comma-separated
> unsigned
> >> > +integers that specify max number of VFs for PF0 (left of the
> >> > +comma) and PF1 (right of the comma); for 23xx only. By default HW
> >> > +will configure as many VFs as queues after allocating PF queues.To
> >> > +increase queues for VF use this parameter. Use sysfs to create
> >> > +these VFs.");
> >> > +
> >> > +static unsigned int num_queues_per_pf[2] =3D { 0, 0 };
> >> > +module_param_array(num_queues_per_pf, uint, NULL, 0444);
> >> > +MODULE_PARM_DESC(num_queues_per_pf, "two comma-separated
> >> unsigned
> >> > +integers that specify number of queues per PF0 (left of the comma)
> >> > +and PF1 (right of the comma); for 23xx only");
> >> > +
> >> >  static int ptp_enable =3D 1;
> >>
> >> We cannot continue to allow drivers to add custom module parameters
> >> to control this.  It is the worst user experience possible.
> >>
> >> We need a tree-wide generic, consistent, manner in which to configure
> >> and control this kind of thing.
> >
> > Sure Dave, I will remove max_vfs module parameter and will use tree
> > wide generic sysfs interface to enable VFs.
>=20
> That's not what I meant.
>=20
> I mean there needs to be a generic mechanism that isn't a per-device knob
> (be it a module parameter or a sysctl, to me these are identical function=
ality
> and user experience wise).
>=20
> Something like ethtool or netlink.

Dave, I will remove max_vfs module parameter and will just use the generic =
mechanism that all drivers do like:

" echo 10 > /sys/devices/pci0000:00/0000:00:03.0/0000:03:00.1/sriov_numvfs"

Regarding other module parameters, in non-default case if user wants to hav=
e multiple queues then because of the way Liquidio HW works we need num_que=
ues_per_pf and num_queues_per_vf module parameters at HW/module init time. =
This is because in multi-queues per VF scenario, HW has to carve these queu=
es before FW can start communicating with PF/VF host drivers, so we must in=
clude these two parameters.=20

Please confirm that having these two module parameters is fine for non-defa=
ult case. I will soon forward you the patches with these changes that you h=
ave recommended.

Thanks Much
Raghu.
