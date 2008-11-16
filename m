From: "Andrew Shewmaker" <agshew@gmail.com>
Subject: Re: [RFC PATCH 00/13] hardware time stamping + igb example implementation
Date: Sun, 16 Nov 2008 01:15:46 -0700
Message-ID: <f4050c9e0811160015y1eab6c63xd08d9485f5c642f1@mail.gmail.com>
References: <1226414697.17450.852.camel@ecld0pohly>
	 <491AFF09.8070907@linux.intel.com>
	 <1226507118.31699.91.camel@ecld0pohly> <491B23FE.9000105@hartkopp.net>
	 <491B2D03.1090700@cosmosbay.com> <491B3B49.7070402@linux.intel.com>
	 <491B42FF.3000407@cosmosbay.com> <491B4BE3.3010104@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>,
	"Oliver Hartkopp" <oliver@hartkopp.net>,
	"Patrick Ohly" <patrick.ohly@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Octavian Purdila" <opurdila@ixiacom.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	"Ingo Oeser" <netdev@axxeo.de>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Andi Kleen" <ak@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.191]:53271 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbYKPIPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 03:15:47 -0500
Received: by rn-out-0910.google.com with SMTP id k40so1706583rnd.17
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2008 00:15:46 -0800 (PST)
In-Reply-To: <491B4BE3.3010104@linux.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2008 at 2:34 PM, Andi Kleen <ak@linux.intel.com> wrote:
>> TCP trafic wont use hwtstamp.
>
> Actually it wouldn't surprise me if one of the numerous
> TCP congestion avoidance algorithms that get added all the time
> starts making use of such an enhanced time stamp.

I would like point to CUBIC, the Probe Control Protocol, and TCP Santa
Cruz as evidence that you are correct.

CUBIC v2.3 has a new slow start variant called Hystart.

http://marc.info/?l=linux-netdev&m=122531684115306&w=2

In their tech report, they refer to the packet train technique for
measuring available bandwidth used by Dovrolis in his Pathload tool.
One of the reasons Hystart uses heuristics rather than the algorithms
described in the Pathload paper is the unavailability of high
precision timestamps.

http://www.cc.gatech.edu/fac/Constantinos.Dovrolis/pathload.html

The Probe Control Protocol is a non-TCP protocol.  The authors
implemented the Pathload algorithm for measuring available bandwidth,
but they used libpcap to do it.

http://www.cs.washington.edu/research/networking/pcp/


TCP Santa Cruz is another, older, variant of TCP that proposed using
timestamps to model the depth of the queue in the bottleneck switch
between two hosts.
http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.6.981


And lastly, I would welcome good TX and RX timestamps for use with my
own research in providing better QoS on commodity networks.

-- 
Andrew Shewmaker
