From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Mon, 14 Mar 2005 17:29:58 -0800
Message-ID: <42363A96.2090601@hp.com>
References: <200503150108.j2F18FDD016965@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <200503150108.j2F18FDD016965@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alex Aizman wrote:
> Andi Kleen writes: 
> 
> 
>>I guess the main objection to the HAL comes not from 
>>performance issues 
> 
> 
> But the second or the third objection comes from there, I guess... As far as
> the data path, HAL as a "layer" completely disappears. There is just a few
> inline instructions that post descriptors and process completed descriptors.
> These same instructions are unavoidable; they'd be present HAL or no-HAL.
> There's no HAL locks on the data path (the locks are compiled out), no HAL
> (as a "layer") induced overhead. Note that the performance was one
> persistent "paranoia" from the very start of this project.
> 
> The numbers also tell the tale. We have 7.6Gbps jumbo throughput, the
> bottleneck is PCI, not the host.

That would seem to suggest then comparing (using netperf terminology) service 
demands between HAL and no HAL.  JumboFrame can compensate for a host of ills :) 
I really do _not_ mean to imply there are any ills for which compensation is 
required, just suggesting to get folks into the habit of including CPU 
utilization.  And since we cannot count on JumboFrame being there end-to-end, 
performance with 1500 byte frames, while perhaps a bit unpleasant, is still 
important.

> We have 13us 1byte netpipe latency. 

So 76,000 transactions per second on something like single-byte netperf 
TCP_RR?!? Or am I mis-interpreting the netpipe latency figure?

I am of course biased, but netperf (compiled with -DUSE_PROCSTAT under Linux, 
somethign else for other OSes - feel free to contact me about it) tests along 
the lines of:

netperf -c -C -t TCP_STREAM -H <remote> -l <length> -i 10,3 -- -s 256K -S 256K 
-m 32K

and

netperf -c -C -t TCP_RR -H <remote> -l <length> -i 10,3

are generally useful.  If you have the same system type at each end, the -C can 
be dropped from the TCP_RR test since it _should_ be symmetric.  If -C dumps 
core on the TCP_STREAM test, drop it and add a TCP_MAERTS test to get receive 
service demand.

rick jones
