From: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH] fsl/fman: remove of_node
Date: Tue, 10 Oct 2017 14:01:43 +0000
Message-ID: <DB3PR0402MB3849B765C1046AE869C0A0C9EC750@DB3PR0402MB3849.eurprd04.prod.outlook.com>
References: <1506940297-20442-1-git-send-email-madalin.bucur@nxp.com>
        <20171002.160445.737065995396076298.davem@davemloft.net>
        <AM5PR0402MB26914CBD37E3F28C17562258EC720@AM5PR0402MB2691.eurprd04.prod.outlook.com>
 <20171003.214357.2276688669726195045.davem@davemloft.net>
 <AM5PR0402MB2691AA6167F9C9A68C058797EC730@AM5PR0402MB2691.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "junote@outlook.com" <junote@outlook.com>
To: Madalin-cristian Bucur <madalin.bucur@nxp.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM5PR0402MB2691AA6167F9C9A68C058797EC730@AM5PR0402MB2691.eurprd04.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Madalin-cristian Bucur
> Sent: Wednesday, October 04, 2017 12:54 PM
> To: David Miller <davem@davemloft.net>
> Subject: RE: [PATCH] fsl/fman: remove of_node
>=20
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Wednesday, October 04, 2017 7:44 AM
> > To: Madalin-cristian Bucur <madalin.bucur@nxp.com>
> > Cc: netdev@vger.kernel.org; andrew@lunn.ch; f.fainelli@gmail.com; linux=
-
> > kernel@vger.kernel.org
> > Subject: Re: [PATCH] fsl/fman: remove of_node
> >
> > From: Madalin-cristian Bucur <madalin.bucur@nxp.com>
> > Date: Tue, 3 Oct 2017 08:49:31 +0000
> >
> > > My patch removes the of_node that was set to a device that was not an
> > > of_device, preventing duplicated probing of both the real of_device
> > > and the "fake" one created through this assignment.
> > >
> > > I understand that the DSA issue that triggered the initial change
> > > was related to DSA finding the network devices using
> > > of_find_net_device_by_node(), something that will not work for the
> > > DPAA case where the netdevice does not have an of_node. I do not know
> > > enough about DSA to come up with a solution for this problem now.
> > > Andrew, Florian, can you please comment on this?
> >
> > It sounds like you're knowingly breaking DSA.
>=20
> It never worked, even with the change I'm reverting.

I'll resend this change as part of a patch set that changes the device
used as net_dev dev to ensure DSA will find a of_device there. To make
that work some changes to adjust link (that also make it cleaner) were
needed. Also, to keep the old udev rules happy, I've changed the names
of the FMan kernel modules from fsl_fman_* to fsl_dpaa_fman*.

I do not have a DSA setup to test so I just tested the part related to
of_find_net_device_by_node() being able to determine the net_device
based on a device tree handle using an artificial device tree and code
construct. I hope that will help the initial reporter of the DSA issue
on DPAA (Junote Cai).

Madalin
