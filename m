From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression with poll(2)
Date: Tue, 21 Aug 2012 07:16:11 +0200
Message-ID: <1345526171.5158.364.camel@edumazet-glaptop>
References: <alpine.DEB.2.00.1208151226250.15721@cobra.newdream.net>
	 <alpine.DEB.2.00.1208191051150.15570@cobra.newdream.net>
	 <20120820090443.GA3275@suse.de>
	 <1345455059.5158.302.camel@edumazet-glaptop>
	 <20120820162046.f827f758.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mel Gorman <mgorman@suse.de>, Sage Weil <sage@inktank.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org,
	neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu,
	emunson@mgebm.net, sebastian@breakpoint.cc, cl@linux.com,
	torvalds@linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <20120820162046.f827f758.akpm@linux-foundation.org>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-08-20 at 16:20 -0700, Andrew Morton wrote:
> On Mon, 20 Aug 2012 11:30:59 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Mon, 2012-08-20 at 10:04 +0100, Mel Gorman wrote:
> > 
> > > Can the following patch be tested please? It is reported to fix an fio
> > > regression that may be similar to what you are experiencing but has not
> > > been picked up yet.
> > > 
> > > -
> > 
> > This seems to help here.
> > 
> > Boot your machine with "mem=768M" or a bit less depending on your setup,
> > and try a netperf.
> > 
> > -> before patch :
> > 
> > # netperf
> > MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> > localhost.localdomain () port 0 AF_INET
> > Recv   Send    Send                          
> > Socket Socket  Message  Elapsed              
> > Size   Size    Size     Time     Throughput  
> > bytes  bytes   bytes    secs.    10^6bits/sec  
> > 
> >  87380  16384  16384    14.00       6.05   
> > 
> > -> after patch :
> > 
> > Recv   Send    Send                          
> > Socket Socket  Message  Elapsed              
> > Size   Size    Size     Time     Throughput  
> > bytes  bytes   bytes    secs.    10^6bits/sec  
> > 
> >  87380  16384  16384    10.00    18509.73   
> 
> "seem to help"?  Was previous performance fully restored?

I did some tests this morning on my HP Z600, and got same numbers than
3.5.0

Of course, its a bit difficult to say, because there is no
CONFIG_PFMEMALLOC to test real impact.



