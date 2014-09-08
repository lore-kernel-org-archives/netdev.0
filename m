From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: RE: [PATCH 1/4] net: stmmac: enhance to support multiple device
 instances
Date: Mon, 8 Sep 2014 03:10:43 +0000
Message-ID: <F54AEECA5E2B9541821D670476DAE19C2B7E8827@PGSMSX102.gar.corp.intel.com>
References: <cover.1409123378.git.hock.leong.kweh@intel.com>
	<cover.1409123378.git.hock.leong.kweh@intel.com>
	<cf29eb9e793cf67b99b455f3a4a55e7aca5d826c.1409123378.git.hock.leong.kweh@intel.com>
 <20140829.200623.1931173830496862001.davem@davemloft.net>
 <F54AEECA5E2B9541821D670476DAE19C2B6E74EE@PGSMSX102.gar.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "'peppe.cavallaro@st.com'" <peppe.cavallaro@st.com>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>,
	"Ong, Boon Leong" <boon.leong.ong@intel.com>,
	'Rayagond K' <rayagond@vayavyalabs.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F54AEECA5E2B9541821D670476DAE19C2B6E74EE@PGSMSX102.gar.corp.intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Kweh, Hock Leong
> Sent: Saturday, August 30, 2014 11:48 AM
> To: David Miller
> Cc: peppe.cavallaro@st.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Ong, Boon Leong; Rayagond K
> Subject: RE: [PATCH 1/4] net: stmmac: enhance to support multiple device
> instances
> 
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Saturday, August 30, 2014 11:06 AM
> > > From: Kweh Hock Leong <hock.leong.kweh@intel.com>
> > >Date: Wed, 27 Aug 2014 18:32:26 +0800
> > >
> > > +static int instance_id = 1;
> >
> > Don't do this instance stuff.  Instead pull in some identifier that
> > can come from elsewhere.
> 
> Regarding this, I would like to open up a discussion here. This "instance_id"
> actually is used for registering the mdio bus as a bus id. The original code use
> "1" for the bus id. If the system plug in more than one stmmac pci cards, I
> believe there is conflict on the mdio bus registration. So introduce this static
> global variable is to increase the bus id starting from "1" base on how many
> stmmac pci cards being plugged in.
> 
> So, to change the "instance_id" by using some identifier, the only thing come
> to my mind is pci_dev->devfn number. Is anyone have concern about using
> devfn number as an mdio bus id ?

Hi David and everyone,

Just gently ping to see if any concern about the above discussion that
removing the instance_id and use the PCI_DEVID number for the mdio bus
number registration as showed below:

-static void stmmac_default_data(void)
+static void stmmac_default_data(struct plat_stmmacenet_data *plat_dat,
+                                                                   struct pci_dev *pdev)
 {
-       plat_dat.bus_id = 1;
+       plat_dat->bus_id = PCI_DEVID(pdev->bus->number, pdev->devfn);


Looking forward to get inputs from you guys. I will send the 2nd version
by this Wed if no one have concern to this. Thanks.


Regards,
Wilson
