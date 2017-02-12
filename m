From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v4 1/2] qed: Add infrastructure for PTP support.
Date: Sun, 12 Feb 2017 15:02:02 +0100
Message-ID: <20170212140202.GA1702@localhost.localdomain>
References: <1486536194-30872-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1486536194-30872-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170211085810.GA4006@localhost.localdomain>
 <20170211111638.GA6564@localhost.localdomain>
 <BL2PR07MB2306C87FF3E79B221675F5848D460@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34288 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751206AbdBLOCI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 09:02:08 -0500
Received: by mail-wr0-f196.google.com with SMTP id 89so20371287wrr.1
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 06:02:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <BL2PR07MB2306C87FF3E79B221675F5848D460@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 12, 2017 at 11:27:16AM +0000, Mintz, Yuval wrote:
> Richard, there are quite a bit of inaccuracies in the calculation here.

Where?

If you compare this algorithm with yours, you will discover that it
produces significantly lower error for ppm < 60.

> Your suggestion seems to:
>   a. Assume that the required period should be in ns, not in
>       16*ns units.
>   b. mishandles the +8/-8 in the calculation.
>   c. Doesn't seem to consider the upper bound on period.

Duh, you would have to convert the result into the proper form for the
HW register and add bounds checking.  I mean, that goes without saying.
The important fact is that your algorithm it not optimal for ppm < 60.

(I assumed that the -8 thing was a typical HW programming effect,
where you dial N-1 to get N.  The fact that you add 8 back in to
calculate the effective ppb confirms that assumption.  If this isn't
the case, then maybe you can see a way to adapt what I wrote.)

> One thing I still don't get is *why* we're trying to optimize this
> area of the code -

So you prefer using 21 64-bit divisions when using 8 produces better
results?

*You* need to explain the "why"...

Thanks,
Richard
