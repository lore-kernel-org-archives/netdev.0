From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH 4/4] arm/dts: am33xx: Add CPSW and MDIO module nodes for
 AM33XX
Date: Fri, 2 Nov 2012 08:46:46 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293EA08F53@DBDE01.ent.ti.com>
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
	Richard Cochran <richardcochran@gmail.com>
To: "Cousson, Benoit" <b-cousson@ti.com>,
	"Hiremath, Vaibhav" <hvaibhav@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <50914107.2090909@ti.com>
Content-Language: en-US
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Cousson, Benoit
> Sent: Wednesday, October 31, 2012 8:47 PM
> To: Hiremath, Vaibhav
> Cc: netdev@vger.kernel.org; paul@pwsan.com; linux-arm-
> kernel@lists.infradead.org; linux-omap@vger.kernel.org; N, Mugunthan V;
> Richard Cochran
> Subject: Re: [PATCH 4/4] arm/dts: am33xx: Add CPSW and MDIO module
> nodes for AM33XX
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
> Do you have to store all these data in the DTS? Cannot it be in the
> driver?
> 
> Do you expect to have several instance of the same IP with different
> parameters here?

Though CPSW is a single IP in AM335X, CPSW has sub modules like CPDMA, ALE,
SLIVER, CPTS and SLAVES where is IP integrator can locate it at different
offsets. For example comparing the CPSW ip in TI814X and AM335X all the
above offsets are changed. So I have kept all these offsets in DT as driver
should not hold any SoC related informations

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

I have followed the naming convention as per the TRM which is mentioned as
Slave 0 and Slave 1 and its offset is from 0x4a100000. I have taken the
reference from  arch/arm/boot/dts/picoxcell-pc3x2.dtsi+167 and followed
the same naming convention from TRM. There is one more method to implement
in reference from arch/arm/boot/dts/imx6q.dtsi+408 as below

+			cpsw_emac0: slave@208 {
+				slave_reg_ofs = <0x208>;
+				sliver_reg_ofs = <0xd80>;
+				/* Filled in by U-Boot */
+				mac-address = [ 00 00 00 00 00 00 ];
+			};

Regards
Mugunthan V N 

