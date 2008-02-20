From: Tony Battersby <tonyb@cybernetics.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Wed, 20 Feb 2008 10:18:58 -0500
Message-ID: <47BC44E2.9060301@cybernetics.com>
References: <47BA0984.2070306@cybernetics.com> <1203381120.13495.78.camel@dell> <20080218.163554.74130592.davem@davemloft.net> <1203383046.13495.87.camel@dell> <47BB00EC.3010607@cybernetics.com> <1203448265.13495.95.camel@dell> <47BB54C2.6090501@cybernetics.com> <20080220034515.GC22703@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, gregkh@suse.de,
	linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.cybernetics.com ([70.169.137.4]:2419 "EHLO
	mail.cybernetics.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751728AbYBTPS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 10:18:59 -0500
In-Reply-To: <20080220034515.GC22703@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Feb 19, 2008 at 05:14:26PM -0500, Tony Battersby wrote:
>   
>> Update: when I revert Herbert's patch in addition to applying your
>> patch, the iSCSI performance goes back up to 115 MB/s again in both
>> directions.  So it looks like turning off SG for TX didn't itself cause
>> the performance drop, but rather that the performance drop is just
>> another manifestation of whatever bug is causing the data corruption.
>>     
>
> Interesting.  So the workload that regressed is mostly RX with a
> little TX traffic? Can you try to reproduce this with something
> like netperf to eliminate other variables?
>
> This is all very puzzling since the patch in question shouldn't
> change an RX load at all.
>
> Thanks,
>   
We have established that the slowdown was caused by TCP checksum errors
and retransmits.  I assume that the slowdown in my test was due to the
light TX rather than the heavy RX.  I am no TCP protocol expert, but
perhaps heavy TX (such as iperf) might not be affected as much because
the wire stays busy while waiting for the retransmit, whereas with my
light TX iSCSI load, the wire goes idle while waiting for the retransmit
because the iSCSI state machine is stalled.

Tony

