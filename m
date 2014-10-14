From: "Frank.Li@freescale.com" <Frank.Li@freescale.com>
Subject: RE: [PATCH] net: fec: ptp: fix convergence issue to support LinuxPTP
 stack
Date: Tue, 14 Oct 2014 18:27:28 +0000
Message-ID: <7e6db0b336a340bd80b62475fca284fc@BLUPR03MB486.namprd03.prod.outlook.com>
References: <1413265187-5228-1-git-send-email-b38611@freescale.com>
	<20141014103610.GA4019@localhost.localdomain>
 <20141014.125239.1562178476120218308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>,
	"richardcochran@gmail.com" <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0141.outbound.protection.outlook.com ([157.56.111.141]:42432
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753373AbaJNS1d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 14:27:33 -0400
In-Reply-To: <20141014.125239.1562178476120218308.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, October 14, 2014 11:53 AM
> To: richardcochran@gmail.com
> Cc: Duan Fugang-B38611; netdev@vger.kernel.org; bhutchings@solarflare.com; Li
> Frank-B20596
> Subject: Re: [PATCH] net: fec: ptp: fix convergence issue to support LinuxPTP
> stack
> 
> From: Richard Cochran <richardcochran@gmail.com>
> Date: Tue, 14 Oct 2014 12:36:10 +0200
> 
> > On Tue, Oct 14, 2014 at 01:39:47PM +0800, Fugang Duan wrote:
> >> IEEE 1588 module has one hw issue in capturing the ATVR register.
> >> According to the user manual it is:
> >> 		ENET0->ATCR |= ENET_ATCR_CAPTURE_MASK;
> >> 		while(ENET0->ATCR & ENET_ATCR_CAPTURE_MASK);
> >> 		ts_counter_ns = ENET0->ATVR;
> >
> > ...
> >
> >> diff --git a/drivers/net/ethernet/freescale/fec_ptp.c
> >> b/drivers/net/ethernet/freescale/fec_ptp.c
> >> index cca3617..380bb10 100644
> >> --- a/drivers/net/ethernet/freescale/fec_ptp.c
> >> +++ b/drivers/net/ethernet/freescale/fec_ptp.c
> >> @@ -82,12 +82,17 @@ static cycle_t fec_ptp_read(const struct
> >> cyclecounter *cc)  {
> >>  	struct fec_enet_private *fep =
> >>  		container_of(cc, struct fec_enet_private, cc);
> >> +	const struct platform_device_id *id_entry =
> >> +		platform_get_device_id(fep->pdev);
> >>  	u32 tempval;
> >>
> >>  	tempval = readl(fep->hwp + FEC_ATIME_CTRL);
> >>  	tempval |= FEC_T_CTRL_CAPTURE;
> >>  	writel(tempval, fep->hwp + FEC_ATIME_CTRL);
> >>
> >> +	if (id_entry->driver_data & FEC_QUIRK_BUG_CAPTURE)
> >> +		udelay(1);
> >> +
> >
> > What? You never had
> >
> > 	while(ENET0->ATCR & ENET_ATCR_CAPTURE_MASK);
> >
> > in the first place. Maybe you should try that.
> >
> > Did this code ever work? I guess not.
> 
> Also see Luwei Zhou's series:
> 
> http://patchwork.ozlabs.org/patch/398467/
> http://patchwork.ozlabs.org/patch/398465/
> http://patchwork.ozlabs.org/patch/398466/
> 
> Let's get down to the bottom of all of this before I apply anything.  Does this
> fec PTP code work at all?

Yes, Luwei's 3 patch tested at MX6Q, MX6DL platform.

Only i.MX6SX has the problem, which fixed by fugang's patch.

i.MX6SX's ptp have the same issue even though without luwei's patch.

So luwei's patch is independent with fugang's patch.

Luwei's patch use hardware ptp adjustment method.
Fugang's patch fix the problem existed in MX6SX platform.

So I suggest apply luwei's 3 patches firstly.

Best regards
Frank Li
