From: "luwei.zhou@freescale.com" <luwei.zhou@freescale.com>
Subject: RE: [PATCH v1 0/4] Enable FEC pps ouput
Date: Wed, 8 Oct 2014 03:30:24 +0000
Message-ID: <b40848ed739c466683239d317870350a@BY2PR03MB441.namprd03.prod.outlook.com>
References: <1411632621-17429-1-git-send-email-b45643@freescale.com>
 <20141003082341.GB4249@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0124.outbound.protection.outlook.com ([65.55.169.124]:4544
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753180AbaJHDa2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 23:30:28 -0400
In-Reply-To: <20141003082341.GB4249@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 3, 2014 at 04:24:00PM, Richard Cochran wrote:
> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Friday, October 03, 2014 4:24 PM
> To: Zhou Luwei-B45643
> Cc: davem@davemloft.net; netdev@vger.kernel.org; shawn.guo@linaro.org;
> bhutchings@solarflare.com; Estevam Fabio-R49496; Duan Fugang-B38611; Li
> Frank-B20596; stephen@networkplumber.org
> Subject: Re: [PATCH v1 0/4] Enable FEC pps ouput
> 
> On Thu, Sep 25, 2014 at 04:10:17PM +0800, Luwei Zhou wrote:
> > This patch does:
> > 	- Replace 32-bit free-running PTP timer with 31-bit.
> > 	- Implement hardware PTP timestamp adjustment.
> > 	- Enable PPS output based on hardware adjustment.
> >
> >
> > Luwei Zhou (4):
> >   net: fec: ptp: Use the 31-bit ptp timer.
> >   net: fec: ptp: Use hardware algorithm to adjust PTP counter.
> >   net: fec: ptp: Enalbe PPS ouput based on ptp clock
>                    ^^^^^^     ^^^^^
>                    Enable     output
> 
> Also, it looks like you have implemented the wrong feature.
> 
> The "pps" capability means that the clock provides a PPS event
> (interrupt) to the kernel.
> 
> IOW, if .pps==1, then you must call ptp_clock_event() with event type
> PTP_CLOCK_PPS.
> 
> Your patch set seems to be creating a periodic output and not a PPS
> kernel callback.
> 
> You should clarify what you are trying to do, and then implement the
> appropriate interface in your driver.
> 
> Thanks,
> Richard


Hum..The FEC IP does not support a specified channel for PPS function. So I have to use
a ptp timer output channel to implement the PPS function. That is why the software flow
looks like the periodic output but the function is PPS function. We only want the event to happen
on the  per second. So I think it should be clarified to be PPS event. 

Thanks
Luwei
