From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v3 1/5] net-timestamp: extend SCM_TIMESTAMPING
 ancillary data struct
Date: Thu, 24 Jul 2014 16:48:04 -0400
Message-ID: <CA+FuTSfMzbvGAM--LmB6i1R5cGZchmQqMNYkbcQGBn6jRAWG9A@mail.gmail.com>
References: <1405971357-22830-2-git-send-email-willemb@google.com>
 <20140721.162448.2136956416390069389.davem@davemloft.net> <CA+FuTScobCk5EFgsht=S0mfF4fVh1fKqAAV8+mZLk9h1O_uwnA@mail.gmail.com>
 <20140723.211256.2143360320648788946.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	david.daney@cavium.net, Chad Reese <kreese@caviumnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:53530 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934176AbaGXUsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 16:48:35 -0400
Received: by mail-vc0-f174.google.com with SMTP id la4so5913462vcb.33
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 13:48:34 -0700 (PDT)
In-Reply-To: <20140723.211256.2143360320648788946.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I can't believe we're going to hold onto syststamp just for one
> odd-ball MIPS ethernet driver.  Really?
>
> I think putting in whatever work is necessary to convert Octeon over
> to exposing a proper PTP device is much better than having this
> syststamp thing rot in our data structures forever.

Implementing ptp_clock_info gettime/settime/adjtime/adjfreq using
CVMX_MIO_PTP_CLOCK_[CFG|HI|COMP] might be feasible.

That does not address legacy application dependencies on syststamp.
Even with a PTP device, it is unclear whether anyone would invest time
to convert their application to use it. The most relevant code I could
find is cavium ptp-1588v2 on github. That configures SO_TIMESTAMPING
to generate both raw + sys tstamps and preferentially reads the first.
If this is the only known octeon timestamping user, then it would be
just as safe to simply remove syststamp.
