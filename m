From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Thu, 14 Aug 2014 08:24:39 +0000
Message-ID: <e84f5b51501e4add8cf08819c64ef554@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1407905705-27984-1-git-send-email-b38611@freescale.com>
 <1407905705-27984-2-git-send-email-b38611@freescale.com>
 <20140813211941.GB4840@netboy>
 <4dcf48cd1c11473c82fcec0c8963ece2@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814081036.GB7555@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0204.outbound.protection.outlook.com ([207.46.163.204]:40565
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751629AbaHNIYx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 04:24:53 -0400
In-Reply-To: <20140814081036.GB7555@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com> Sent: Thursday, August 14, 2014 4:11 PM
>To: Duan Fugang-B38611
>Cc: shawn.guo@linaro.org; davem@davemloft.net; netdev@vger.kernel.org
>Subject: Re: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg
>clock is disabled
>
>On Thu, Aug 14, 2014 at 01:28:28AM +0000, fugang.duan@freescale.com wrote:
>> If the ethx close, ptp stack cannot run normally, stack stop send sync
>> message with master,
>
>But this has no effect on whether transmit time stamps are enabled.
>
>The timer work must run whenever the (physical) clock is running.
>Otherwise you will have discontinuities in your PTP clock.
>The kernel must always behave correctly, regardless of what user space
>does.
>
>When the user calls clock_gettime(), the result must always be consistent.
>This has nothing to do with time stamping at all.
>
I have some points against your views:
1. HW ptp is one feature of FEC IP, when the ethx interface is closed, ptp slave cannot sync with master,
   So the ptp timer is not accurate, of couse there have discontinuities in ptp clock.
2. When the ethx net interface is closed, FEC IP clocks are disabled, access ptp counter register causes
   Hw hang.
3. PTP is not separate HW IP, which is one hw feature of FEC IP, when the net interface is closed, user
   Call clock_gettime() is not reasonable.

Thanks,
Andy
