From: "Hiremath, Vaibhav" <hvaibhav@ti.com>
Subject: RE: [PATCH 4/4] arm/dts: am33xx: Add CPSW and MDIO module nodes for
 AM33XX
Date: Wed, 31 Oct 2012 19:52:13 +0000
Message-ID: <79CD15C6BA57404B839C016229A409A83EB56C41@DBDE01.ent.ti.com>
References: <1351498881-32482-1-git-send-email-hvaibhav@ti.com>
 <1351498881-32482-6-git-send-email-hvaibhav@ti.com> <50914107.2090909@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"paul@pwsan.com" <paul@pwsan.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>,
	Richard Cochran <richardcochran@gmail.com>
To: "Cousson, Benoit" <b-cousson@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <50914107.2090909@ti.com>
Content-Language: en-US
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 31, 2012 at 20:47:27, Cousson, Benoit wrote:
> Hi,
> 
> On 10/29/2012 09:21 AM, Vaibhav Hiremath wrote:
> > From: Mugunthan V N <mugunthanvnm@ti.com>
> > 
> > Add CPSW and MDIO related device tree data for AM33XX.
> > Also enable them into board/evm dts files by providing
> > respective phy-id.
> 
> Is there any bindings documentation for that device?
> 

Yes, the base DT binding documentation is present in file
Documentation/devicetree/bindings/net/cpsw.txt


> > Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> > Signed-off-by: Vaibhav Hiremath <hvaibhav@ti.com>
> > Cc: Richard Cochran <richardcochran@gmail.com>
> > Cc: Benoit Cousson <b-cousson@ti.com>
> > ---
> >  arch/arm/boot/dts/am335x-bone.dts |    8 ++++++
> >  arch/arm/boot/dts/am335x-evm.dts  |    8 ++++++
> >  arch/arm/boot/dts/am33xx.dtsi     |   50 +++++++++++++++++++++++++++++++++++++
> >  3 files changed, 66 insertions(+), 0 deletions(-)
> > 
> > diff --git a/arch/arm/boot/dts/am335x-bone.dts b/arch/arm/boot/dts/am335x-bone.dts
> > index c634f87..e233cfa 100644
> > --- a/arch/arm/boot/dts/am335x-bone.dts
> > +++ b/arch/arm/boot/dts/am335x-bone.dts
> > @@ -78,3 +78,11 @@
> >  		};
> >  	};
> >  };
> > +
> > +&cpsw_emac0 {
> > +	phy_id = "4a101000.mdio:00";
> 
> Why are you using that kind of interface? You seem to want a reference
> to a device.
> 
> Cannot you have something less hard coded like:
> phy_id = <&davinci_mdio>, <0>;
> 
> 
> > +};
> > +
> > +&cpsw_emac1 {
> > +	phy_id = "4a101000.mdio:01";
> > +};
> > diff --git a/arch/arm/boot/dts/am335x-evm.dts b/arch/arm/boot/dts/am335x-evm.dts
> > index 185d632..415c3b3 100644
> > --- a/arch/arm/boot/dts/am335x-evm.dts
> > +++ b/arch/arm/boot/dts/am335x-evm.dts
> > @@ -118,3 +118,11 @@
> >  		};
> >  	};
> >  };
> > +
> > +&cpsw_emac0 {
> > +	phy_id = "4a101000.mdio:00";
> > +};
> > +
> > +&cpsw_emac1 {
> > +	phy_id = "4a101000.mdio:01";
> > +};
> > diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
> > index bb31bff..f6bea04 100644
> > --- a/arch/arm/boot/dts/am33xx.dtsi
> > +++ b/arch/arm/boot/dts/am33xx.dtsi
> > @@ -210,5 +210,55 @@
> >  			interrupt-parent = <&intc>;
> >  			interrupts = <91>;
> >  		};
> > +
> > +		mac: ethernet@4A100000 {
> 
> hexa data should be in lower case.
> 

Oops. Will correct it.

> > +			compatible = "ti,cpsw";
> > +			ti,hwmods = "cpgmac0";
> > +			cpdma_channels = <8>;
> > +			host_port_no = <0>;
> > +			cpdma_reg_ofs = <0x800>;
> > +			cpdma_sram_ofs = <0xa00>;
> > +			ale_reg_ofs = <0xd00>;
> > +			ale_entries = <1024>;
> > +			host_port_reg_ofs = <0x108>;
> > +			hw_stats_reg_ofs = <0x900>;
> > +			bd_ram_ofs = <0x2000>;
> > +			bd_ram_size = <0x2000>;
> > +			no_bd_ram = <0>;
> > +			rx_descs = <64>;
> > +			mac_control = <0x20>;
> 
> Do you have to store all these data in the DTS? Cannot it be in the driver?
> 
> Do you expect to have several instance of the same IP with different
> parameters here?
> 

I will let Mugunthan respond to this.


> > +			slaves = <2>;
> > +			reg = <0x4a100000 0x800
> > +				0x4a101200 0x100
> > +				0x4a101000 0x100>;
> 
> Please align the address.

Ok.

> 
> > +			#address-cells = <1>;
> > +			#size-cells = <1>;
> > +			interrupt-parent = <&intc>;
> > +			/* c0_rx_thresh_pend c0_rx_pend c0_tx_pend c0_misc_pend*/
> 
> Please use a standard multi-line comment instead of trying to put
> everything in one line.
> 

Oops. Will correct it.

> > +			interrupts = <40 41 42 43>;
> > +			ranges;
> 
> You should add blank line here for readability.
> 

OK.


> > +			cpsw_emac0: slave@0 {
> 
> Mmm, you are using some address later and here some relative number,
> that does not looks very consistent.
> 
> > +				slave_reg_ofs = <0x208>;
> 
> Is it an offset from 4a100000? Cannot you use the address for the slave
> name?
> 
> Something like that: cpsw_emac0: slave@4a100208
>
> > +				sliver_reg_ofs = <0xd80>;
> > +				/* Filled in by U-Boot */
> > +				mac-address = [ 00 00 00 00 00 00 ];
> > +			};
> 
> You should add blank line here for readability.
> 

Ok

Thanks,
Vaibhav
