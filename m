From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression with poll(2)
Date: Mon, 20 Aug 2012 11:30:59 +0200
Message-ID: <1345455059.5158.302.camel@edumazet-glaptop>
References: <alpine.DEB.2.00.1208151226250.15721@cobra.newdream.net>
	 <alpine.DEB.2.00.1208191051150.15570@cobra.newdream.net>
	 <20120820090443.GA3275@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sage Weil <sage@inktank.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ceph-devel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl,
	michaelc@cs.wisc.edu, emunson@mgebm.net, sebastian@breakpoint.cc,
	cl@linux.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org
To: Mel Gorman <mgorman@suse.de>
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <20120820090443.GA3275@suse.de>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-08-20 at 10:04 +0100, Mel Gorman wrote:

> Can the following patch be tested please? It is reported to fix an fio
> regression that may be similar to what you are experiencing but has not
> been picked up yet.
> 
> -

This seems to help here.

Boot your machine with "mem=768M" or a bit less depending on your setup,
and try a netperf.

-> before patch :

# netperf
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
localhost.localdomain () port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    14.00       6.05   

-> after patch :

Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.00    18509.73   


