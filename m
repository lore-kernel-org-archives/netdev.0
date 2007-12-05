From: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Wed, 05 Dec 2007 07:12:00 +0100
Message-ID: <47564130.6020503@ee.ethz.ch>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill>	<474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch>	<4753B423.7030000@trash.net> <4753C874.80703@ee.ethz.ch>	<47543E65.4060303@trash.net> <47544B1F.1010902@candelatech.com> <20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch> <47559119.6070803@candelatech.com> <47559455.1080009@ee.ethz.ch> <47559763.9050408@candelatech.com> <4755C984.70906@ee.ethz.ch> <4755D2EB.4000807@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:48707 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751568AbXLEGMF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 01:12:05 -0500
In-Reply-To: <4755D2EB.4000807@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> If you actually run out of the trace buffers, do you just continue to
> run with the last settings?  If so, that would keep up throughput
> even if you are out of trace buffers...

Upon configuring the qdisc you can specify a default value, which is 
taken when the buffers are empty. It is either drop the packet or just 
forward it with no delay.

> What rates do you see, btw?  (pps, bps).
My machine was an AMD Athlon 2083MHz, with a default installation of 
Debian with Kernel 2.6.16 and HZ set to 1000.
Up to 80'000 pps (with "small" udp packets) everything (without netem, 
with netem and with netem trace) worked fine (tested with up to 10ms delay).
For 90'000 pps the kernel dropped some packets even with no netem 
running, some more with netem and allmost all with netem trace.

As soon as I have changed the mechanism for the data transfer to 
rtnetlink I'll do some new tests, trying to reach a higher packet rate. 
Then I'll see whether it is necessary to add more buffers, or whether 
the system collapses before.

Thanks again!
Ariane


