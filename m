From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: ipsec impact on performance
Date: Tue, 1 Dec 2015 20:09:26 -0500
Message-ID: <20151202010926.GH23178@oracle.com>
References: <20151201175953.GC21252@oracle.com>
 <565DE446.2070609@hpe.com>
 <565E41B8.1080206@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <565E41B8.1080206@cumulusnetworks.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (12/01/15 16:56), David Ahern wrote:
> 
> Using iperf3 and AH with NULL algorithm between 2 peers connected by
> a 10G link.
> 
I'm using esp-null, not AH, and iperf2, which I understand is 
quite different from, and more aggressive than, iperf3 (though I'm not 
sure that it matters for this single-stream case).

> With AH I get ~1.5 Gbps with MTU at 1500:

But yes, I get approx that too. 

The "good" news is that I can get about 3 Gbps with my patch. So one
could say that I've 2x-ed the perf. Except that:

The "bad" news is that even GSO/GRO can do way better, so we
need to be able to extend that perf to also be available 
to some key TCP and IP extensions (like md5 and ipsec, maybe)
and beyond (i.e need to de-ossify the stack so we can extend
TCP/IP features without sacrificing perf along the way).

The not-so-great news is that I see that just adding perf tracepoints
(not even enabling them!) seems to make a small diff (3 Gbps vs 3.2 Gbps) 
to my numbers. Is that mere standard-deviation, or something 
one should be aware of, about perf?

> iperf3 runs about 60% CPU and ksoftirqd/2 is at 86%.

yes, not surprising. You really need to compare this to GSO/GRO
for a pure-s/w,  apples-apples comparison.

> Bumping the MTU to 9000:

Yes that's not always an option. See also the comments from Eric/Rick
about latency [http://lists.openwall.net/netdev/2015/11/24/111]. 

--Sowmini
