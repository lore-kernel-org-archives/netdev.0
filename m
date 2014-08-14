From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Thu, 14 Aug 2014 09:02:07 +0000
Message-ID: <4977c4d325c949019549211d74c6982d@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1407905705-27984-1-git-send-email-b38611@freescale.com>
 <1407905705-27984-2-git-send-email-b38611@freescale.com>
 <20140813211941.GB4840@netboy>
 <4dcf48cd1c11473c82fcec0c8963ece2@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814081036.GB7555@netboy>
 <e84f5b51501e4add8cf08819c64ef554@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814084251.GC7555@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0205.outbound.protection.outlook.com ([207.46.163.205]:21548
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752196AbaHNJC3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 05:02:29 -0400
In-Reply-To: <20140814084251.GC7555@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com> Sent: Thursday, August 14, 2014 4:43 PM
>To: Duan Fugang-B38611
>Cc: shawn.guo@linaro.org; davem@davemloft.net; netdev@vger.kernel.org
>Subject: Re: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg
>clock is disabled
>
>On Thu, Aug 14, 2014 at 08:24:39AM +0000, fugang.duan@freescale.com wrote:
>> 1. HW ptp is one feature of FEC IP, when the ethx interface is closed,
>ptp slave cannot sync with master,
>>    So the ptp timer is not accurate, of couse there have discontinuities
>in ptp clock.
>
>No, it just becomes a free running clock.
>
>This is no different than the Linux system clock. It keeps running, even
>if ntpd is not.
>
>> 2. When the ethx net interface is closed, FEC IP clocks are disabled,
>access ptp counter register causes
>>    Hw hang.
>
>Well, then, you need to return an error, don't you?

I know your means. Even if cancel the time_keep work, ptp timer still is running and continutious.
The time_keep work just to avoid timer overrun because FEC just support 32bit counter.

fec_time_keep()
{
...
ns = timecounter_read(&fep->tc);
...
}

static cycle_t fec_ptp_read(const struct cyclecounter *cc)
{
...
        tempval = readl(fep->hwp + FEC_ATIME_CTRL);
        tempval |= FEC_T_CTRL_CAPTURE;
        writel(tempval, fep->hwp + FEC_ATIME_CTRL);

        return readl(fep->hwp + FEC_ATIME);
...
}

And, you said "return an error", I don't know your mean.
In addition, when clock is disabled, FEC ptp counter don't run any more.

>
>> 3. PTP is not separate HW IP, which is one hw feature of FEC IP, when
>the net interface is closed, user
>>    Call clock_gettime() is not reasonable.
>
>Yes, it is. See #1.
>
>Thanks,
>Richard
