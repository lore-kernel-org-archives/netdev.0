From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Van Jacobson's net channels and real-time
Date: Mon, 24 Apr 2006 10:19:36 -0700
Message-ID: <444D08A8.3060908@hp.com>
References: <Pine.LNX.4.44L0.0604201819040.19330-100000@lifa01.phys.au.dk>	<200604221529.59899.ioe-lkml@rameria.de>	<20060422134956.GC6629@wohnheim.fh-wedel.de>	<200604230205.33668.ioe-lkml@rameria.de>	<444CFFE5.1020509@intel.com> <Pine.LNX.4.61.0604241254180.24099@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	Ingo Oeser <ioe-lkml@rameria.de>,
	=?ISO-8859-1?Q?J=F6rn_Engel?= <joern@wohnheim.fh-wedel.de>,
	Ingo Oeser <netdev@axxeo.de>,
	"David S. Miller" <davem@davemloft.net>, simlo@phys.au.dk,
	linux-kernel@vger.kernel.org, mingo@elte.hu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:25236 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S1750994AbWDXRUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2006 13:20:08 -0400
To: "linux-os (Dick Johnson)" <linux-os@analogic.com>
In-Reply-To: <Pine.LNX.4.61.0604241254180.24099@chaos.analogic.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>Thats right. This will be made a non issue with early demuxing
>>>on the NIC and MSI (or was it MSI-X?) which will select
>>>the right CPU based on hardware channels.
>>
>>MSI-X. with MSI you still have only one cpu handling all MSI interrupts and
>>that doesn't look any different than ordinary interrupts. MSI-X will allow
>>much better interrupt handling across several cpu's.
>>
>>Auke
>>-
> 
> 
> Message signaled interrupts are just a kudge to save a trace on a
> PC board (read make junk cheaper still). They are not faster and
> may even be slower. They will not be the salvation of any interrupt
> latency problems. The solutions for increasing networking speed,
> where the bit-rate on the wire gets close to the bit-rate on the
> bus, is to put more and more of the networking code inside the
> network board. The CPU get interrupted after most things (like
> network handshakes) are complete.

if the issue is bus vs network bitrates would offloading really buy that 
much?  i suppose that for minimum sized packets not DMA'ing the headers 
across the bus would be a decent win, but down at small packet sizes 
where headers would be 1/3 to 1/2 the stuff DMA'd around, I would think 
one is talking more about CPU path lengths than bus bitrates.

and up and "full size" segments, since everyone is so fond of bulk 
transfer tests, the transfer saved by not shovig headers across the bus 
is what 54/1448 or ~3.75%

spreading interrupts via MSI-X seems nice and all, but i keep wondering 
if the header field-based distribution that is (will be) done by the 
NICs is putting the cart before the horse - should the NIC essentially 
be telling the system the CPU on which to run the application, or should 
the CPU on which the application runs be telling "networking" where it 
should be happening?

rick jones
