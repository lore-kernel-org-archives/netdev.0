From: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH] fsl/fman: remove of_node
Date: Wed, 4 Oct 2017 09:59:58 +0000
Message-ID: <AM5PR0402MB2691DAD9404B336D92F42ED9EC730@AM5PR0402MB2691.eurprd04.prod.outlook.com>
References: <1506940297-20442-1-git-send-email-madalin.bucur@nxp.com>
 <20171002.160445.737065995396076298.davem@davemloft.net>
 <AM5PR0402MB26914CBD37E3F28C17562258EC720@AM5PR0402MB2691.eurprd04.prod.outlook.com>
 <20171003130032.GI13548@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171003130032.GI13548@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Tuesday, October 03, 2017 4:01 PM
> To: Madalin-cristian Bucur <madalin.bucur@nxp.com>
> Cc: David Miller <davem@davemloft.net>; netdev@vger.kernel.org;
> f.fainelli@gmail.com; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH] fsl/fman: remove of_node
>=20
> On Tue, Oct 03, 2017 at 08:49:31AM +0000, Madalin-cristian Bucur wrote:
> > > -----Original Message-----
> > > From: David Miller [mailto:davem@davemloft.net]
> > > Sent: Tuesday, October 03, 2017 2:05 AM
> > > To: Madalin-cristian Bucur <madalin.bucur@nxp.com>
> > > Subject: Re: [PATCH] fsl/fman: remove of_node
> > >
> > > From: Madalin Bucur <madalin.bucur@nxp.com>
> > > Date: Mon, 2 Oct 2017 13:31:37 +0300
> > >
> > > > The FMan MAC driver allocates a platform device for the Ethernet
> > > > driver to probe on. Setting pdev->dev.of_node with the MAC node
> > > > triggers the MAC driver probing of the new platform device. While
> > > > this fails quickly and does not affect the functionality of the
> > > > drivers, it is incorrect and must be removed. This was added to
> > > > address a report that DSA code using of_find_net_device_by_node()
> > > > is unable to use the DPAA interfaces. Error message seen before
> > > > this fix:
> > > >
> > > > fsl_mac dpaa-ethernet.0: __devm_request_mem_region(mac) failed
> > > > fsl_mac: probe of dpaa-ethernet.0 failed with error -16
> > > >
> > > > Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
> > >
> > > Is the DSA issue no longer something we need to be concerned
> > > about?  If not, why?  You have to explain this.
> >
> > My patch removes the of_node that was set to a device that was not an
> > of_device, preventing duplicated probing of both the real of_device
> > and the "fake" one created through this assignment.
> >
> > I understand that the DSA issue that triggered the initial change
> > was related to DSA finding the network devices using
> > of_find_net_device_by_node(), something that will not work for the
> > DPAA case where the netdevice does not have an of_node. I do not know
> > enough about DSA to come up with a solution for this problem now.
> > Andrew, Florian, can you please comment on this?
> >
> > Thanks,
>=20
> Hi Madalin
>=20
> I guess the real fix is to throw away the platform device. But that is
> a big change.
>=20
> I've not looked at the code in detail. Why is the platform device
> needed?
>=20
> 	Andrew

There are multiple components that are aggregated by the DPAA Ethernet
netdevice, the FMan MAC is one of them. There is no entry in the device
tree for the Ethernet device as this is just a software construct that
binds together multiple pieces from the DPAA FMan, QMan, BMan. The probing
of the Ethernet driver is performed against a platform device that is creat=
ed
in the FMan MAC. Setting the of_node in the new platform device makes it
look like an of_device without being one, thus the errors at the MAC driver
probing against the platform device.

Does DSA work for systems that do not use a device tree to boot, i.e. ACPI?

Madalin
