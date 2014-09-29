From: "luwei.zhou@freescale.com" <luwei.zhou@freescale.com>
Subject: RE: [PATCH v2 3/4] ptp: Add PTP_PF_PPS enumeration to
 ptp_pin_function.
Date: Mon, 29 Sep 2014 09:38:44 +0000
Message-ID: <ee73b9239ea9417e976fdf2c51b2fd60@BY2PR03MB441.namprd03.prod.outlook.com>
References: <1411878011-21767-1-git-send-email-b45643@freescale.com>
 <1411878011-21767-4-git-send-email-b45643@freescale.com>
 <20140929085613.GA9891@netboy>
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
Received: from mail-bn1on0132.outbound.protection.outlook.com ([157.56.110.132]:40960
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753076AbaI2Jit convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 05:38:49 -0400
In-Reply-To: <20140929085613.GA9891@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2014,at 4:56:00PM +0800, Richard Cochran wrote:
> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Monday, September 29, 2014 4:56 PM
> To: Zhou Luwei-B45643
> Cc: davem@davemloft.net; netdev@vger.kernel.org; shawn.guo@linaro.org;
> bhutchings@solarflare.com; Estevam Fabio-R49496; Duan Fugang-B38611; Li
> Frank-B20596; stephen@networkplumber.org
> Subject: Re: [PATCH v2 3/4] ptp: Add PTP_PF_PPS enumeration to
> ptp_pin_function.
> 
> On Sun, Sep 28, 2014 at 12:20:10PM +0800, Luwei Zhou wrote:
> 
> > diff --git a/include/linux/ptp_clock_kernel.h
> > b/include/linux/ptp_clock_kernel.h
> > index 0d8ff3f..2a5ad1c 100644
> > --- a/include/linux/ptp_clock_kernel.h
> > +++ b/include/linux/ptp_clock_kernel.h
> > @@ -49,6 +49,7 @@ struct ptp_clock_request {
> >   * @n_alarm:   The number of programmable alarms.
> >   * @n_ext_ts:  The number of external time stamp channels.
> >   * @n_per_out: The number of programmable periodic signals.
> > + * @n_pps_chan: The number of programmable channles for pps output.
> >   * @n_pins:    The number of programmable pins.
> >   * @pps:       Indicates whether the clock supports a PPS callback.
> >   * @pin_config: Array of length 'n_pins'. If the number of @@ -99,6
> > +100,7 @@ struct ptp_clock_info {
> >  	int n_alarm;
> >  	int n_ext_ts;
> >  	int n_per_out;
> > +	int n_pps_chan;
> 
> We don't need this. There is only *one* PPS channel.
> 
> We only want to select which of 'n_pins' will be the PPS output.
Yes, there is only one PPS out. But this pin can choose one channel from index (0~3). I am trying to use n_pps_chan to be the max channel index check.
I am a little puzzled. The FEC PTP has 4 channel and we output only one PPS signal. User need to tell driver which channel index is used.  In this
Case, n_pins should be 1 or 4?
My understanding is n_pins should be 1 because there is only one PPS output 
> 
> >  	int n_pins;
> >  	int pps;
> >  	struct ptp_pin_desc *pin_config;
> > diff --git a/include/uapi/linux/ptp_clock.h
> > b/include/uapi/linux/ptp_clock.h index f0b7bfe..57ba7e7 100644
> > --- a/include/uapi/linux/ptp_clock.h
> > +++ b/include/uapi/linux/ptp_clock.h
> > @@ -86,6 +86,7 @@ enum ptp_pin_function {
> >  	PTP_PF_EXTTS,
> >  	PTP_PF_PEROUT,
> >  	PTP_PF_PHYSYNC,
> > +	PTP_PF_PPS,
> >  };
> >
> >  struct ptp_pin_desc {
> > --
> > 1.9.1
> >
> 
> Thanks,
> Richard

Thanks,
Luwei
