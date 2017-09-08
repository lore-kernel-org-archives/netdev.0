From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH RFC 5/5] Add KSZ8795 SPI driver
Date: Fri, 8 Sep 2017 17:35:40 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41121E1C@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A95@CHN-SV-EXMX02.mchp-main.com>
 <20170908092614.GB18365@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrew@lunn.ch>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
To: <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170908092614.GB18365@amd>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Pavel Machek [mailto:pavel@ucw.cz]
> Sent: Friday, September 08, 2017 2:26 AM
> To: Tristram Ha - C24268
> Cc: andrew@lunn.ch; muvarov@gmail.com; nathan.leigh.conrad@gmail.com;
> vivien.didelot@savoirfairelinux.com; f.fainelli@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Woojung Huh - C21699
> Subject: Re: [PATCH RFC 5/5] Add KSZ8795 SPI driver
> 
> Hi!
> 
> 
> > +static int ksz_spi_read(struct ksz_device *dev, u32 reg, u8 *data,
> > +			unsigned int len)
> > +{
> > +	struct spi_device *spi = dev->priv;
> > +
> > +	return ksz_spi_read_reg(spi, reg, data, len); }
> > +
> > +static int ksz_spi_read8(struct ksz_device *dev, u32 reg, u8 *val) {
> > +	return ksz_spi_read(dev, reg, val, 1); }
> > +
> > +static int ksz_spi_read16(struct ksz_device *dev, u32 reg, u16 *val) {
> > +	int ret = ksz_spi_read(dev, reg, (u8 *)val, 2);
> > +
> > +	if (!ret)
> > +		*val = be16_to_cpu(*val);
> > +
> > +	return ret;
> > +}
> 
> > +static int ksz_spi_read32(struct ksz_device *dev, u32 reg, u32 *val) {
> > +	int ret = ksz_spi_read(dev, reg, (u8 *)val, 4);
> > +
> > +	if (!ret)
> > +		*val = be32_to_cpu(*val);
> > +
> > +	return ret;
> > +}
> 
> Please format according to CodingStyle. (Not only this.)
> 
> And this will be common for more drivers. Can it go to a header file
> and be included...?
> 

Sorry about the formatting.  It seems my e-mail system needs to be checked
to make sure it does not auto-format the contents again.

About the SPI access functions they are the same for each driver except the
low level ksz_spi_read_reg and ksz_spi_write_reg.  The dev_io_ops structure
should contain only those 2 and ksz_spi_get and ksz_spi_set.

But that requires changing ksz_spi.c.  The idea was to keep the code of
KSZ9477 driver with little change as possible while introducing another driver.

The KSZ9477 driver will need to be updated with some of the code in KSZ8795
driver regarding port membership and MIB counter reading.
