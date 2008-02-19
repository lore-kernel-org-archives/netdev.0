From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Tue, 19 Feb 2008 11:11:05 -0800
Message-ID: <1203448265.13495.95.camel@dell>
References: <47BA0984.2070306@cybernetics.com>
 <1203381120.13495.78.camel@dell>
 <20080218.163554.74130592.davem@davemloft.net>
 <1203383046.13495.87.camel@dell> <47BB00EC.3010607@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev <netdev@vger.kernel.org>, gregkh@suse.de,
	linux-kernel@vger.kernel.org
To: "Tony Battersby" <tonyb@cybernetics.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2237 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752696AbYBSTIj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 14:08:39 -0500
In-Reply-To: <47BB00EC.3010607@cybernetics.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-02-19 at 11:16 -0500, Tony Battersby wrote:
> iSCSI
> performance drops to 6 - 15 MB/s when the 3Com NIC is doing heavy rx
> with light tx,

That's strange.  The patch should only affect TX performance slightly
since we are just turning off SG for TX.  Please take an ethereal trace
to see what's happening and compare with a good trace.

> but remains at a decent 115 MB/s when the 3Com NIC is
> doing heavy tx with light rx.  When I revert Herbert's patch instead
> of
> applying the patch above, I get 115 MB/s in both cases.  (With a stock
> unpatched kernel, the test fails almost immediately because the iSCSI
> control PDUs are corrupted, causing the TCP connection to be dropped.)
> 
> The SysKonnect NIC that does not exhibit this problem has a chip that
> says "BCM5411KQM" "TT0128 P2Q" and "56975E".
> 

I think this is the 5700, but please send me the tg3 output that
identifies the chip and the revision.  Something like this:

eth2: Tigon3 [partno(BCM95705) rev 3003 PHY(5705)] (PCI:66MHz:32-bit) 10/100/1000Base-T Ethernet 00:10:18:04:57:0d
eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[0] TSOcap[1]





