From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] Use RCU for tcp_ehash lookup
Date: Wed, 1 Sep 2004 22:45:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040901224546.03765c8d.davem@davemloft.net>
References: <20040831125941.GA5534@in.ibm.com>
	<20040831135419.GA17642@wotan.suse.de>
	<20040901113641.GA3918@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, davem@redhat.com, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, dipankar@in.ibm.com, paulmck@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: vatsa@in.ibm.com
In-Reply-To: <20040901113641.GA3918@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 1 Sep 2004 17:06:41 +0530
Srivatsa Vaddagiri <vatsa@in.ibm.com> wrote:

> On Tue, Aug 31, 2004 at 03:54:20PM +0200, Andi Kleen wrote:
> > I bet also when you just do rdtsc timing for the TCP receive
> > path the cycle numbers will be way down (excluding the copy).
> 
> I got cycle numbers for the lookup routine (with CONFIG_PREEMPT turned off).
> They were taken on a 900MHz 8way Intel P3 SMP box.  The results are as below:
> 
> 
> -------------------------------------------------------------------------------
> 			     |	2.6.8.1		      |	2.6.8.1 + my patch
> -------------------------------------------------------------------------------
> Average cycles 		     |			      |
> spent in 		     |			      |
> __tcp_v4_lookup_established  |	2970.65               |	668.227
> 			     | (~3.3 micro-seconds)   | (~0.74 microseconds)
> -------------------------------------------------------------------------------
> 
> This repesents improvement by a factor of 77.5%!

And yet none of your benchmarks show noticable
improvements, which means that this micro-measurement
is totally unimportant in the grand scheme of things
as far as we know.

I'm not adding in a patch that merely provides some
micro-measurement improvement that someone can do a
shamans dance over. :)  If we're going to add this
new level of complexity to the TCP code we need to
see some real usage performance improvement, not just
something that shows up when we put a microscope on
a single function.
