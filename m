From: Rick Jones <rick.jones2@hp.com>
Subject: Re: get beyond 1Gbps with pktgen  on 10Gb nic?
Date: Tue, 11 May 2010 08:12:08 -0700
Message-ID: <4BE973C8.9050801@hp.com>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D752C7@MILEXCH2.ds.jdsu.net> <1273584925.2107.6.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jon Zhou <Jon.Zhou@jdsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:39286 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754395Ab0EKPML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 11:12:11 -0400
In-Reply-To: <1273584925.2107.6.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Tue, 2010-05-11 at 06:13 -0700, Jon Zhou wrote:
> 
>>hi there:
>>
>> anyone can get beyond 1Gbps with pktgen or other SW traffic generator with
>> 10Gb nic(intel 82599 or BCM 57711)? found that some one had met similar
>> situation with broadcom 10G nic but no solution yet
> 
> 
> I don't know about those specific controllers, but you should be able to
> achieve close to 10G line rate with netperf's TCP_STREAM on any recent
> PC server.  UDP throughput tends to be poorer as there is less support
> for offloading segmentation and reassembly.  Performance may also be
> constrained by PCI Express bandwidth (you need a real 8-lane slot) and
> memory bandwidth (a single memory bank may not be enough).

Further, at least in the context of netperf benchmarking, depending on the 
quantity of offloads, and the speed of your cores, you may want to use the 
global -T option to bind netperf, and particularly netserver to a core other 
than the one on which the interrupts were processed.

It is also good to check whether any of the cores in the system are at or near 
saturation (eg 100%ish utilization).

happy benchmarking,

rick jones
