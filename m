From: Pekka Pietikainen <pp@netppl.fi>
Subject: Re: paper
Date: Mon, 27 Jan 2003 22:21:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030127202145.GA3049@netppl.fi>
References: <7BD96DBF-3225-11D7-9775-000A956767EC@lbl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Brian Tierney <bltierney@lbl.gov>
Content-Disposition: inline
In-Reply-To: <7BD96DBF-3225-11D7-9775-000A956767EC@lbl.gov>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jan 27, 2003 at 10:31:00AM -0800, Brian Tierney wrote:
> 
> Hi Pekka
> 
> I thought you might find this paper interesting. Please forward to the  
> appropriate Linux TCP folks.
> Thanks.
> 
> http://www-didc.lbl.gov/papers/PFDL.tierney.pdf
Hi

It was certainly an interesting read. I'll Cc: this reply
netdev@oss.sgi.com, which has  relevant people on it. One idea that 
might help in pinpointing the problem is using oprofile to see where all that
CPU is going (http://oprofile.sourceforge.net) when the bug occurs.
What it does is lets you profile applications/the kernel quite transparently 
and see where all your CPU is going when the errors start happening.
Even if it's not useful in finding this problem, it's certainly a very
cool tool you should look at ;)

To find out the problem, they'll of course need a description of the
environment (kernel versions, network between them, tcpdump logs etc.)

I do remember seeing a similar problem on local GigE too when the zerocopy 
patches first came out. That did get fixed (or maybe just made impossible
to trigger on GigE). Can't remember the details, what happened was that the
cwnd and ssthresh dropped when there was an error and never recovered
(resulting in something like a 80 -> 50-60MB/s performance drop, which 
lasted until the route cache was flushed). 

An evil hack to try is 
/sbin/ip route add 192.168.9.2 ssthresh <largenumber> dev eth0 ,
which might make it "work" (but it's not the right solution, it just 
makes the tcp stack very rude in finding the proper speed to send
after an error :) )

-- 
Pekka Pietikainen
