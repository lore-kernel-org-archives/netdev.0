From: "bhupesh.sharma@freescale.com" <bhupesh.sharma@freescale.com>
Subject: RE: [PATCH] net: can: Remodel FlexCAN register read/write APIs for BE
 instances
Date: Wed, 25 Jun 2014 09:55:10 +0000
Message-ID: <5197da248c48434495eddebae9276072@BN1PR03MB220.namprd03.prod.outlook.com>
References: <1403625285-27824-1-git-send-email-bhupesh.sharma@freescale.com>
 <063D6719AE5E284EB5DD2968C1650D6D17264A8E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "wg@grandegger.com" <wg@grandegger.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0241.outbound.protection.outlook.com ([207.46.163.241]:43034
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754485AbaFYJzN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 05:55:13 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17264A8E@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Laight [mailto:David.Laight@ACULAB.COM]
> Sent: Wednesday, June 25, 2014 2:28 PM
> To: Sharma Bhupesh-B45370; mkl@pengutronix.de; linux-can@vger.kernel.org
> Cc: wg@grandegger.com; netdev@vger.kernel.org
> Subject: RE: [PATCH] net: can: Remodel FlexCAN register read/write APIs
> for BE instances
> 
> From: Bhupesh Sharma
> > The FlexCAN IP on certain SoCs like (Freescale's LS1021A) is modelled
> > in a big-endian fashion, i.e. the registers and the message buffers
> > are organized in a BE way.
> >
> > More details about the LS1021A SoC can be seen here:
> > http://www.freescale.com/webapp/sps/site/prod_summary.jsp?code=LS1021A
> > &nodeId=018rH325E4017B#
> >
> > This patch ensures that the register read/write APIs are remodelled to
> > address such cases, while ensuring that existing platforms (where the
> > FlexCAN IP was modelled in LE way) do not break.
> ...
> Munged to the new code....
> > +static inline u32 flexcan_read(const struct flexcan_priv *priv,
> > +			       void __iomem *addr)
> >  {
> > +	if (priv->devtype_data->module_is_big_endian)
> > +		return ioread32be(addr);
> > +	else
> > +		return ioread32(addr);
> >  }
> >
> > +static inline void flexcan_write(const struct flexcan_priv *priv,
> > +				 u32 val, void __iomem *addr)
> >  {
> > +	if (priv->devtype_data->module_is_big_endian)
> > +		iowrite32be(val, addr);
> > +	else
> > +		iowrite32(val, addr);
> >  }
> 
> Hmmm....
> If performance ever matters that is horrid.
> Probably to the point where making the functions 'inline' is just code
> bloat.
> 

Got the point. See my reply already sent to Marc's review comments.

Regards,
Bhupesh
