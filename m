From: Bill Fink <billfink@mindspring.com>
Subject: Re: Throughput Bug?
Date: Fri, 19 Oct 2007 01:44:19 -0400
Message-ID: <20071019014419.6ac8a6a0.billfink@mindspring.com>
References: <c565abbb0710180854j6f2f756sdd390161bafd1c4a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Matthew Faulkner" <matthew.faulkner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:44143
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752634AbXJSFoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 01:44:24 -0400
In-Reply-To: <c565abbb0710180854j6f2f756sdd390161bafd1c4a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Oct 2007, Matthew Faulkner wrote:

> Hey all
> 
> I'm using netperf to perform TCP throughput tests via the localhost
> interface. This is being done on a SMP machine. I'm forcing the
> netperf server and client to run on the same core. However, for any
> packet sizes below 523 the throughput is much lower compared to the
> throughput when the packet sizes are greater than 524.
> 
> Recv   Send    Send                          Utilization       Service Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local   remote
> bytes  bytes   bytes    secs.    MBytes  /s  % S      % S      us/KB   us/KB
>  65536  65536    523    30.01        81.49   50.00    50.00    11.984  11.984
>  65536  65536    524    30.01       460.61   49.99    49.99    2.120   2.120
> 
> The chances are i'm being stupid and there is an obvious reason for
> this, but when i put  the server and client on different cores i don't
> see this effect.
> 
> Any help explaining this will be greatly appreciated.
> 
> Machine details:
> 
> Linux 2.6.22-2-amd64 #1 SMP Thu Aug 30 23:43:59 UTC 2007 x86_64 GNU/Linux
> 
> sched_affinity is used by netperf internally to set the core affinity.

I don't know if it's relevant, but note that 524 bytes + 52 bytes
of IP(20)/TCP(20)/TimeStamp(12) overhead gives a 576 byte packet,
which is the specified size that all IP routers must handle (and
the smallest value possible during PMTU discovery I believe).  A
message size of 523 bytes would be 1 less than that.  Could this
possibly have to do with ABC (possibly try disabling it if set)?

						-Bill
