From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/3] Revert Backoff [v3]: Calculate TCP's connection
 close threshold as a time value.
Date: Mon, 4 Jun 2012 22:18:19 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1206042116560.17280@melkinpaasi.cs.helsinki.fi>
References: <4A950B82.1070807@tvk.rwth-aachen.de> <CAFbMe2Mu46N8kRrYkGzYRLuntEd2J9aO_d0Jw_y0gsQA4q-qHw@mail.gmail.com> <CAPshTCiFDUb3CVm-joJW_DRVS+C+_BjFO-Mt3uAwrCzVw8MsVg@mail.gmail.com> <1338832247.5299.4.camel@nexus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jerry Chu <hkchu@google.com>, Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41644 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912Ab2FDTYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 15:24:22 -0400
In-Reply-To: <1338832247.5299.4.camel@nexus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Jun 2012, Damian Lukowski wrote:

> please verify, I understood you correctly.
> 
> You have set TCP_RTO_MIN to a lower value, e.g. 0.002 seconds to improve
> your internal low-latency traffic. Because of the improvement, R1
> timeouts are triggered too fast for external high-RTT traffic. Is that
> correct?
> If so, may I suggest to set tcp_retries1 to a higher value? For
> TCP_RTO_MIN == 0.002 and tcp_retries1 ==  10, R1 will be calculated to
> approximately 4 seconds.
> 
> Is that ok?

I suppose what he meant is that you could have e.g., 60sec RTT and with 
small enough retries the timeout calculation yields to some timeout 
smaller than 60 secs, and therefore no retransmissions are made which is 
certainly not a desirable property? ...This is valid issue even if no min 
rto tweaking was done but can of course get much worse if min rto is 
shorter.

I agree with his proposed solution:

> > I think retransmits_timed_out() should check against both time
> > duration and retrans count (icsk_retransmits).

...that is, use both pseudo timeout check of the current code and the 
previously used icsk_retransmits compare at the same time.

-- 
 i.
