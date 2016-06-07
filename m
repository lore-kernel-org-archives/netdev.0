From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: RE: [RESEND PATCH v5 1/2] can: rcar_canfd: Add Renesas R-Car CAN FD
 driver
Date: Tue, 7 Jun 2016 13:18:38 +0000
Message-ID: <SG2PR06MB1038056F44EFBCB51674B832C35D0@SG2PR06MB1038.apcprd06.prod.outlook.com>
References: <KL1PR06MB1031E61B9DD9A59B305CCC15C3590@KL1PR06MB1031.apcprd06.prod.outlook.com>
	<CAO3366wxRkRZyR3nayY5=7sTxk-pWZ-BRjXA7p8OzvuZ-YbvDw@mail.gmail.com>
	<5751BB31.5030708@hartkopp.net>
 <20160603.113902.296916236989519473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "ulrich.hecht@gmail.com" <ulrich.hecht@gmail.com>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Paterson <Chris.Paterson2@renesas.com>,
	"horms@verge.net.au" <horms@verge.net.au>,
	"magnus.damm@gmail.com" <magnus.damm@gmail.com>,
	"linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"socketcan@hartkopp.net" <socketcan@hartkopp.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160603.113902.296916236989519473.davem@davemloft.net>
Content-Language: en-US
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > On 06/03/2016 07:03 PM, Ulrich Hecht wrote:
> >
> >> Thanks; I missed that every register is described twice.
> >>
> >> Nevertheless, names often vary more or less subtly between your patch
> >> and the specs, making it very hard to review. Some have letters
> >> added, some have letters removed, and some are just plain confusing.
> >> For instance, RCANFD_DCFG_* apparently does not describe, as one
> >> might think, RSCFDnCFDCmDCFG, but RSCFDnCFDCmFDCFG. These names are,
> >> of course, completely ridiculous, but inventing a new set makes
> >> things even worse, IMO.
> >
> > ???
> >
> > You suggest to use 'completely ridiculous' definitions in favor to
> > definitions that have a proper name space RCANFD_ ?
> >
> > When there is a more readable way that maintains proper readable code
> > there's no reason to adopt crappy definitions just because some chip
> > designer has no clue how to design proper register names.
> >
> > When there's some mapping from RSCFDnCFDCmFDCFG to RCANFD_DCFG_* this
> > could be mentioned in the comments.
> >
> > But I'm totally against these blurry upper/lower case letter stuff for
> > register definitions.
> 
> I agree with Oliver, these StuDlyCaPS names used in the spec should not be
> used in the driver, they are completely unreadable.

Thanks Oliver, Dave for your inputs.

Hi Uli,

I have added comments to the readable register set mapping them to the clumsy name in h/w manual to aid your review. I have kept the bit name definitions within register exactly as in h/w manual. E.g.

+/* RSCFDnCFDGSTS */
+#define RCANFD_GSTS_GRAMINIT		BIT(3)
+#define RCANFD_GSTS_GSLPSTS		BIT(2)
+#define RCANFD_GSTS_GHLTSTS		BIT(1)
+#define RCANFD_GSTS_GRSTSTS		BIT(0)

I have also sorted the bit definition ordering from MSB to LSB. I will send out the updated patch set next. I hope this addresses your concern.

Please note that I am planning to add classical CAN only mode support next (after the current patch set is accepted). The code is designed to support both modes and hence I have classified the register definitions as "common register set" & "CAN FD specific register set". In future, I will just add the "Classical CAN specific register set" alone without much code re-org.

Thanks,
Ramesh
