From: Brian Tierney <bltierney@lbl.gov>
Subject: Re: paper
Date: Mon, 27 Jan 2003 13:10:46 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <CDE2CBAC-323B-11D7-9775-000A956767EC@lbl.gov>
References: <20030127202145.GA3049@netppl.fi>
Mime-Version: 1.0 (Apple Message framework v551)
Content-Type: text/plain; delsp=yes; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brian Tierney <bltierney@lbl.gov>, Jason Lee <jrlee@lbl.gov>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20030127202145.GA3049@netppl.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The bug is quite easy to replicate, of you have access to the right  
type of network.
You need a path with a RTT > 150 ms, capable of at least 500 Mbps  
throughput.
Then set both the send and receive buffer to 20 MB, and watch what  
happens.

I might be able to provide access to such a network if necessary.

I'll check out oprofile and see what I find.

Hopefully folks will read the paper to see how the combination of  
web100 and NetLogger make a great TCP analysis tool.

Cheers.



On Monday, January 27, 2003, at 12:21 PM, Pekka Pietikainen wrote:

> On Mon, Jan 27, 2003 at 10:31:00AM -0800, Brian Tierney wrote:
>>
>> Hi Pekka
>>
>> I thought you might find this paper interesting. Please forward to the
>> appropriate Linux TCP folks.
>> Thanks.
>>
>> http://www-didc.lbl.gov/papers/PFDL.tierney.pdf


> Hi
>
> It was certainly an interesting read. I'll Cc: this reply
> netdev@oss.sgi.com, which has  relevant people on it. One idea that
> might help in pinpointing the problem is using oprofile to see where  
> all that
> CPU is going (http://oprofile.sourceforge.net) when the bug occurs.
> What it does is lets you profile applications/the kernel quite  
> transparently
> and see where all your CPU is going when the errors start happening.
> Even if it's not useful in finding this problem, it's certainly a very
> cool tool you should look at ;)
>
> To find out the problem, they'll of course need a description of the
> environment (kernel versions, network between them, tcpdump logs etc.)
>
> I do remember seeing a similar problem on local GigE too when the  
> zerocopy
> patches first came out. That did get fixed (or maybe just made  
> impossible
> to trigger on GigE). Can't remember the details, what happened was  
> that the
> cwnd and ssthresh dropped when there was an error and never recovered
> (resulting in something like a 80 -> 50-60MB/s performance drop, which
> lasted until the route cache was flushed).
>
> An evil hack to try is
> /sbin/ip route add 192.168.9.2 ssthresh <largenumber> dev eth0 ,
> which might make it "work" (but it's not the right solution, it just
> makes the tcp stack very rude in finding the proper speed to send
> after an error :) )
>
> --  
> Pekka Pietikainen
>
>
>
>
------------------------------------------------------------------------ 
-------------------
   Brian L. Tierney,   Lawrence Berkeley National Laboratory (LBNL)
   1 Cyclotron Rd.  MS: 50B-2239,  Berkeley, CA  94720
   tel: 510-486-7381    fax: 510-495-2998   efax:  240-332-4065
   bltierney@lbl.gov   http://www-didc.lbl.gov/~tierney
------------------------------------------------------------------------ 
------------------
