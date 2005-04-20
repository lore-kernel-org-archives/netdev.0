From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI, e100, and system performance problem
Date: Wed, 20 Apr 2005 11:15:31 -0400
Message-ID: <1114010131.8916.65.camel@localhost.localdomain>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	 <Pine.LNX.4.61.0504180943290.15052@linux.site>
	 <1113855967.7436.39.camel@localhost.localdomain>
	 <20050419055535.GA12211@sgi.com>
	 <20050419113657.7290d26e.davem@davemloft.net>
	 <20050420145629.GH19415@sgi.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, akepner@sgi.com,
        jesse.brandeburg@intel.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20050420145629.GH19415@sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-21-04 at 00:56 +1000, Greg Banks wrote:

> We have a stats package called PCP (see oss.sgi.com) which samples
> all kinds of stuff out of /proc at a configurable polling frequency,
> default 2 sec, and provides scrolling graphs.  We've also done some
> profiling work using the SGI kernprof patch in 2.4 kernels and
> oprofile in 2.6 kernels.
> 

this may not be sufficient to debug; that PCP sounds like a hog in its
own merit polling /proc.

Actually, lets start by saying this:
If you problem is PIO being too expensive on your machines, then the
solution maybe for you to set coalescing parameters appropriately. This
is a known issue - "fixing NAPI" requires complicating things for the
majority who dont have the same problem as you.
The issue pointed out by Rick Jones that you sacrifice latency is still
valid. Additionaly, with many NICs in place, coalescing is not gonna cut
it.

Having said that - here are some items that will be useful to collect
before and after a run:

- netstat -s output
- /proc/net/softnet_stat
- ifconfig output
- tc -s qdisc on the interfaces 
- oprofile 
- any other thing you could come up with like some of the stuff you
posted recently on how many packets/interupt are processed with and
without NAPI.
- preferably run UDP tests so we dont have to think hard about stats
like retransmits etc.
- And as pointed by Dave, pick the latest kernel.

cheers,
jamal
