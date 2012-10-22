From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH V2 0/7] support the cpts found on am335x devices
Date: Mon, 22 Oct 2012 10:39:40 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293E9FD697@DBDE01.ent.ti.com>
References: <cover.1350329726.git.richardcochran@gmail.com>
 <EB1619762EAF8B4E97A227FB77B7E0293E9F82F0@DBDE01.ent.ti.com>
 <20121016171407.GA2176@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293E9F86E9@DBDE01.ent.ti.com>
 <20121017182714.GC2412@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	"Chemparathy, Cyril" <cyril@ti.com>,
	"Govindarajan, Sriramakrishnan" <srk@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:54544 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752112Ab2JVKjw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 06:39:52 -0400
In-Reply-To: <20121017182714.GC2412@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Wednesday, October 17, 2012 11:57 PM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; linux-arm-kernel@lists.infradead.org; David
> Miller; Chemparathy, Cyril; Govindarajan, Sriramakrishnan
> Subject: Re: [PATCH V2 0/7] support the cpts found on am335x devices
> 
> On Tue, Oct 16, 2012 at 11:11:29PM +0000, N, Mugunthan V wrote:
> >
> > Yes, I do agree that driver handles it. As Half roll over and Full
> roll
> > over events are not handled in the driver, I am just curious how will
> > the misaligned TS would be handled and also in cpts set time, the
> Lower
> > 32 bit time is written to CPTS counter
> 
> #include <linux/clocksource.h>

I think the timecounter_init initializes only the software. But still I am
not clear how the time given in cpts_ptp_settime will be projected to
hardware. Can you correct me if I am wrong.

> 
> > Since we poll for the 32bit over flow for every HZ * 8 cycle, won't
> > there be a system overhead. If the CPTS ref clock is changed
> according
> > to the ptp freq adjust api, how will the timecounter take care of
> change
> > in frequency
> 
> There is nothing to do here. What are you asking?

I think instead of fixing the driver to AM335X, let's make the driver
generic as the same driver can be used to TI814X, TI813X and other
upcoming platforms TI811X where the CPTS ref clock can be changed as
per usage requirement.

> 
> > The current driver which is in vanilla kernel doesn't use extended
> slave
> > address which are conflict between TI814x CPSW IP version and AM335x
> CPSW
> > IP version. I have just posted my version of CPTS implementation. May
> be
> > we can work together make the driver compatible with both CPSW
> versions
> 
> Okay.
> 
> > Since CPSW is a 3port Switch we should not fix time stamping will be
> enabled
> > only for slave 0 or passing slave number through DT. Its better if we
> > can configure both the slaves. This can be tested with EVM-sk which
> has
> > both the slave ports pinned out.
> 
> I hope that you meant, "better if we can configure _either_ slave."
> Considering how SO_TIMESTAMPING works, you can't use both at once.
> 

Since CPSW as a Ethernet switch, the PTP packet can be delivered to
any downstream port. So if we fix the PTP time stamping to one port
then the driver won't receive time stamping information when the packet
is delivered to the other port.

Regards
Mugunthan V N
