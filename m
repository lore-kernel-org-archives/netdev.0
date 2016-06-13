From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: use RFC6298 compliant TCP RTO calculation
Date: Mon, 13 Jun 2016 14:19:26 -0700
Message-ID: <1465852766.7945.177.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160613204529.18826-1-dmetz@mytum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hagen Paul Pfeifer <hagen@jauu.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Daniel Metz <dmetz@mytum.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32930 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423106AbcFMVT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 17:19:28 -0400
Received: by mail-pa0-f41.google.com with SMTP id b13so26828799pat.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 14:19:28 -0700 (PDT)
In-Reply-To: <20160613204529.18826-1-dmetz@mytum.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-13 at 22:45 +0200, Daniel Metz wrote:
> This patch adjusts Linux RTO calculation to be RFC6298 Standard
> compliant. MinRTO is no longer added to the computed RTO, RTO damping
> and overestimation are decreased.
> 
> In RFC 6298 Standard TCP Retransmission Timeout (RTO) calculation the
> calculated RTO is rounded up to the Minimum RTO (MinRTO), if it is
> less. The Linux implementation as a discrepancy to the Standard
> basically adds the defined MinRTO to the calculated RTO. When
> comparing both approaches, the Linux calculation seems to perform
> worse for sender limited TCP flows like Telnet, SSH or constant bit
> rate encoded transmissions, especially for Round Trip Times (RTT) of
> 50ms to 800ms.
> 
> Compared to the Linux implementation the RFC 6298 proposed RTO
> calculation performs better and more precise in adapting to current
> network characteristics. Extensive measurements for bulk data did not
> show a negative impact of the adjusted calculation.
> 
> Exemplary performance comparison for sender-limited-flows:
> 
> - Rate: 10Mbit/s
> - Delay: 200ms, Delay Variation: 10ms
> - Time between each scheduled segment: 1s
> - Amount Data Segments: 300
> - Mean of 11 runs
> 
>          Mean Response Waiting Time [milliseconds]
> 
> PER [%] |   0.5      1    1.5      2      3      5      7     10
> --------+-------------------------------------------------------
> old     | 206.4  208.6  218.0  218.6  227.2  249.3  274.7  308.2
> new     | 203.9  206.0  207.0  209.9  217.3  225.6  238.7  259.1
> 
> 
> Detailed Analysis:
> 
> https://docs.google.com/document/d/1pKmPfnQb6fDK4qpiNVkN8cQyGE4wYDZukcuZfR-BnnM/
> 
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> Signed-off-by: Daniel Metz <dmetz@mytum.de>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---
> 
> We removed outdated comments in the code, though more cleanup may required.
> 

It seems you left mdev_max_us ?
