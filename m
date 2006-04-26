From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] e1000 performance patch
Date: Wed, 26 Apr 2006 15:26:17 -0700
Message-ID: <444FF389.2090002@hp.com>
References: <20060426221353.GA22143@lemming.cita.utoronto.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:62617 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S964872AbWDZW0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 18:26:20 -0400
To: Robin Humble <rjh@cita.utoronto.ca>
In-Reply-To: <20060426221353.GA22143@lemming.cita.utoronto.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robin Humble wrote:
> [I sent this to the e1000-devel folks, and they suggested netdev might
>  have opinions too. the below text has changed a little bit to reflect
>  feedback from Auke Kok]
> 
> attached is a small patch for e1000 that dynamically changes Interrupt
> Throttle Rate for best performance - both latency and bandwidth.
> it makes e1000 look really good on netpipe with a ~28 us latency and
> 890 Mbit/s bandwidth.
> 
> the basic idea is that high InterruptThrottleRate (~200k) is best for
> small messages, 

Best for small numbers of small messages?  If one is looking to have 
high aggregate small packet rates, the higher throttle rate may degrade 
the peak PPS one can achieve.

> I've done an analysis of performance on this page:
>   http://www.cita.utoronto.ca/mediawiki/index.php/E1000_performance_patch
> our hardware details are there too.
> there's also a link to another analysis of how the patch affects routing
> performance and cpu usage (surprisingly better).
> 
> despite the netpipe improvements, I haven't seen much in the way of real
> world code differences (either +ve or -ve) from a regular 15k ITR. I've
> seen an improvement in one code, and a slight degradation (~1%) in HPL
> (top500.org benchmark). it should probably make the most difference for
> codes that consistantly send small (< 1k) messages.

Tweaking interrupt coalescing parameters was rather common in SPECweb 
benchmarking. If you examine some of the results on www.spec.org you may 
see examples.  IIRC the last ones I submitted used an interrupt throttle 
rate of something like 700.  It was a small but non-trivial percentage 
difference in the SPECweb result.

rick jones

It is a bit rough/messy as a writeup, but here is what I've seen wrt the 
latency vs throughput tradeoffs:

ftp://ftp.cup.hp.com/dist/networking/briefs/nic_latency_vs_tput.txt
