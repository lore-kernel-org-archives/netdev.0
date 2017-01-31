From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] qede: Add driver support for PTP.
Date: Tue, 31 Jan 2017 15:53:18 +0100
Message-ID: <20170131145318.GA18274@localhost.localdomain>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-3-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170129153536.GD2223@localhost.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6DB0273BA8@AcuExch.aculab.com>
 <BL2PR07MB2306B5963EBDEF0AF5CD4E8F8D4B0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <063D6719AE5E284EB5DD2968C1650D6DB02749AC@AcuExch.aculab.com>
 <BL2PR07MB23068B30A71CB67A8DE673E48D4A0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35267 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750962AbdAaPB3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 10:01:29 -0500
Received: by mail-wm0-f68.google.com with SMTP id u63so16072253wmu.2
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 07:01:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <BL2PR07MB23068B30A71CB67A8DE673E48D4A0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 02:31:41PM +0000, Mintz, Yuval wrote:
> I feel like I'm missing something. Again.
> I thought the reasonable rate of rate-adjustment is once a second,
> which doesn't make it 'hot' in any way.
> In which scenario would we frequently encounter this configuration?

The Sync message rate is not 1 per second, but rather the interval is
specified by the PTP profile as 2^N seconds, -128 <= N < 128.

This is called the logSyncInterval, and in the Telecom profile [1] for
example, N = -4.

Anyhow, as far the original question goes, maybe you could have the
specific HW driver pass its adjfreq function pointer into the generic
driver and let the generic driver copy it directly into the
ptp_clock_info.

Just an idea.

Thanks,
Richard

1. T-REC-G.8275.1-201407
