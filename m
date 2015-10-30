From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v3 net] i40e: Look up MAC address in Open Firmware or
 IDPROM
Date: Fri, 30 Oct 2015 15:24:37 -0400
Message-ID: <20151030192437.GE32759@oracle.com>
References: <20151030150344.GG9312@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACA14@fmsmsx115.amr.corp.intel.com>
 <20151030183645.GD32759@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACA8F@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"andy.shevchenko@gmail.com" <andy.shevchenko@gmail.com>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418AFACA8F@fmsmsx115.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (10/30/15 18:57), Nelson, Shannon wrote:
> > >
> > > Going along with this being the equivalent of the ixgbe patch, I'd
> > > prefer the new code to be in i40e_main.c, rather than in i40e_common.c.
> > > In the design of our drivers, the common file is essentially a device
> > > specific layer, and the OS and platform related stuff should stay in
> > > i40e_main.c.  That would also take care of one of the include file nits
> > > that Andy mentioned.
       :
> I'm not sure about any deeper wisdom, but the HW/FW model that this
> device uses is rather different from our previous devices, so our SW
> abstractions are a little different from ixgbe and igb.

Ok, in that case I can make i40e_main.c to do something like

static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
{
   :
   if (i40e_get_platform_mac_addr(..) != I40E_SUCCESS)
	i40e_get_mac_addr(..);
   :
}

and i agree that doing this from i40e_main will simplify a lot of the
other stuff around getting the pdev etc.

[Discussion about ndo_set_mac_address..]

> In the cases in which I'm aware, the platform manufacturer normally will
> burn a different mac-address into the device's eeprom at manufacturing
> time if they want something other than what came from Intel.  I suppose a
> Device Tree oriented platform could have a different address in the DT,
> but somehow that needs to get communicated to the device driver so that
> it can tell the HW.
> 
> My question to you remains: does this ndo_set_mac_address happen from
> the stack above the driver or not?

I'm probably even less clued in to the DT arch than you in this case,
so input from the intel experts would be useful here.

But both in this case, and for the ixgbe template on which I tried
to model this, the OF/idprom probing happens from the ->probe when the
driver comes up, and ndo_set_mac_address is not involved.

I dont know if it is easier (or even feasible to do this from ->probe) 
to just call the i40e_set_mac to make sure all the state-bits in
the driver are correctly set.

--Sowmini
