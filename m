From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v4 1/2] qed: Add infrastructure for PTP support.
Date: Sun, 12 Feb 2017 19:47:58 +0100
Message-ID: <20170212184758.GA1703@localhost.localdomain>
References: <1486536194-30872-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1486536194-30872-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170211085810.GA4006@localhost.localdomain>
 <20170211111638.GA6564@localhost.localdomain>
 <BL2PR07MB2306C87FF3E79B221675F5848D460@BL2PR07MB2306.namprd07.prod.outlook.com>
 <BL2PR07MB230689D83356C4577C8AB1E58D460@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33105 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750882AbdBLSsD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 13:48:03 -0500
Received: by mail-wm0-f67.google.com with SMTP id v77so15385745wmv.0
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 10:48:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <BL2PR07MB230689D83356C4577C8AB1E58D460@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 12, 2017 at 11:52:23AM +0000, Mintz, Yuval wrote:
> Just to clarify [since it's bit a meaningless otherwise] -
> this +8 is a HW-bug workaround.

Can you please explain exactly what the problem is?

Your code does

		period1 = div_s64(val * 1000000000, ppb);
		period1 -= 8;
		period1 >>= 4;

But correct rounding would be

		period1 = div_s64(val * 1000000000, ppb);
		period1 += 8;
		period1 >>= 4;

Thanks,
Richard
