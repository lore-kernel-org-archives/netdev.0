From: "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>
Subject: RE: [PATCH net-next V2 1/9] liquidio CN23XX: HW config for VF support
Date: Thu, 20 Oct 2016 20:01:37 +0000
Message-ID: <DM3PR07MB21387F2B6D44558DBC36649881D50@DM3PR07MB2138.namprd07.prod.outlook.com>
References: <1476942046-18789-1-git-send-email-rvatsavayi@caviumnetworks.com>
        <1476942046-18789-2-git-send-email-rvatsavayi@caviumnetworks.com>
 <20161020.141304.286994718471308700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>,
        "Burla, Satananda" <Satananda.Burla@cavium.com>,
        "Manlunas, Felix" <Felix.Manlunas@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0059.outbound.protection.outlook.com ([104.47.42.59]:5105
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753133AbcJTURp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 16:17:45 -0400
In-Reply-To: <20161020.141304.286994718471308700.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, October 20, 2016 11:13 AM
> To: Vatsavayi, Raghu
> Cc: netdev@vger.kernel.org; Vatsavayi, Raghu; Chickles, Derek; Burla,
> Satananda; Manlunas, Felix
> Subject: Re: [PATCH net-next V2 1/9] liquidio CN23XX: HW config for VF
> support
>=20
> From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
> Date: Wed, 19 Oct 2016 22:40:38 -0700
>=20
> > +/* Default behaviour of Liquidio is to provide one queue per VF. But
> > +Liquidio
> > + * can also provide multiple queues to each VF. If user wants to
> > +change the
> > + * default behaviour HW should be provided configuration info at init
> > +time,
> > + * based on which it will create control queues for communicating with
> FW.
> > + */
> > +static u32 max_vfs[2] =3D { 0, 0 };
> > +module_param_array(max_vfs, int, NULL, 0444);
> > +MODULE_PARM_DESC(max_vfs, "Assign two comma-separated unsigned
> > +integers that specify max number of VFs for PF0 (left of the comma)
> > +and PF1 (right of the comma); for 23xx only. By default HW will
> > +configure as many VFs as queues after allocating PF queues.To
> > +increase queues for VF use this parameter. Use sysfs to create these
> > +VFs.");
> > +
> > +static unsigned int num_queues_per_pf[2] =3D { 0, 0 };
> > +module_param_array(num_queues_per_pf, uint, NULL, 0444);
> > +MODULE_PARM_DESC(num_queues_per_pf, "two comma-separated
> unsigned
> > +integers that specify number of queues per PF0 (left of the comma)
> > +and PF1 (right of the comma); for 23xx only");
> > +
> >  static int ptp_enable =3D 1;
>=20
> We cannot continue to allow drivers to add custom module parameters to
> control this.  It is the worst user experience possible.
>=20
> We need a tree-wide generic, consistent, manner in which to configure and
> control this kind of thing.

Sure Dave, I will remove max_vfs module parameter and will use tree wide ge=
neric=20
sysfs interface to enable VFs. Also if user wants to have multiple queues t=
hen because=20
of the way Liquidio HW works we need num_queues_per_pf and num_queues_per_v=
f=20
module parameters at HW/module init time. This is required only in case of =
non-default
case of multi-queues per VF because HW has to carve these queues before FW =
can start
communicating with PF/VF host drivers, so we may include these two.=20

I will soon forward you the patches with the changes that you recommended.

Thanks Much.
Raghu.
