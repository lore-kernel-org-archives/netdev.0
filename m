From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: drop all fragments inside tx queue if one gets dropped
Date: Wed, 20 Apr 2016 13:45:50 -0700
Message-ID: <5717EA7E.1020606@hpe.com>
References: <57175156.3050501@pengutronix.de>
 <11312.1461183334@obiwan.sandelman.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Aring <aar@pengutronix.de>
To: Michael Richardson <mcr@sandelman.ca>, netdev@vger.kernel.org,
	linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:33763 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbcDTUp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 16:45:58 -0400
In-Reply-To: <11312.1461183334@obiwan.sandelman.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the "everything old is new again" files, back in the 1990s, it was 
noticed that on the likes of a netperf UDP_STREAM test on HP-UX, with 
fragmentation taking place, it was possible to consume 100% of the link 
bandwidth and have 0% effective throughput because the transmit queue 
was kept full with IP datagram fragments which could not possibly be 
reassembled (*) because one or more of the fragments of a datagram were 
dropped because the transmit queue was full.

HP-UX implemented "packet trains" where all the fragments of a 
fragmented datagram were presented to the driver, which then either 
queued them all, or none of them.

I don't recall seeing similar poor behaviour in Linux; I would have 
assumed that the intra-stack flow-control "took care" of it.  Perhaps 
there is something specific to wpan which precludes that?

happy benchmarking,

rick jones
