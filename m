From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: [net-next 2/3] udp: Add udp early demux
Date: Tue, 1 Oct 2013 17:26:56 -0500
Message-ID: <20131001222656.GA8653@sbohrermbp13-local.rgmadvisors.com>
References: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
 <1380656025-8847-3-git-send-email-sbohrer@rgmadvisors.com>
 <524B2CA2.4090807@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog122.obsmtp.com ([74.125.149.147]:35107 "EHLO
	na3sys009aog122.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752010Ab3JAWeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 18:34:08 -0400
Received: by mail-ie0-f177.google.com with SMTP id qd12so15433399ieb.36
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 15:33:53 -0700 (PDT)
In-Reply-To: <524B2CA2.4090807@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 01, 2013 at 01:12:18PM -0700, Rick Jones wrote:
> On 10/01/2013 12:33 PM, Shawn Bohrer wrote:
> >The removal of the routing cache introduced a performance regression for
> >some UDP workloads since a dst lookup must be done for each packet.
> >This change caches the dst per socket in a similar manner to what we do
> >for TCP by implementing early_demux.
> >
> >For UDP multicast we can only cache the dst if there is only one
> >receiving socket on the host.  Since caching only works when there is
> >one receiving socket we do the multicast socket lookup using RCU.
> >
> >Benchmark results from a netperf UDP_RR test:
> >Before 90596.44 transactions/s
> >After  91296.97 transactions/s
> 
> Were those measured with confidence intervals enabled?  It would be
> a Good Idea (tm) to either use that - I would suggest -I 99,1 -i
> 30,3 added to the global portion of the netperf command line - or
> take several runs.  (If you've not already done so since those look
> more like "raw" netperf numbers rather than theaverage of several
> runs)

Those are the averages from six one minute UDP_RR tests.  If I
re-rerun the netperf numbers I'll use the confidence intervals I did
not know about that feature.  In general I just added these quick
numbers as a point of reference and to double check that some open
source benchmarks could even see a difference.  For me the real
benchmark is my workload which does show a much more significant
difference with these changes.

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
