From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Use RCU for tcp_ehash lookup
Date: Thu, 2 Sep 2004 23:19:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040902211950.GH16175@wotan.suse.de>
References: <20040831125941.GA5534@in.ibm.com> <20040831135419.GA17642@wotan.suse.de> <20040901113641.GA3918@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, davem@redhat.com, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, Dipankar <dipankar@in.ibm.com>,
        paulmck@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Srivatsa Vaddagiri <vatsa@in.ibm.com>
Content-Disposition: inline
In-Reply-To: <20040901113641.GA3918@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 01, 2004 at 05:06:41PM +0530, Srivatsa Vaddagiri wrote:
> 			     |	2.6.8.1		      |	2.6.8.1 + my patch
> -------------------------------------------------------------------------------
> Average cycles 		     |			      |
> spent in 		     |			      |
> __tcp_v4_lookup_established  |	2970.65               |	668.227
> 			     | (~3.3 micro-seconds)   | (~0.74 microseconds)
> -------------------------------------------------------------------------------
> 
> This repesents improvement by a factor of 77.5%!

Nice.

> 
> 
> > 
> > And it should also fix the performance problems with
> > cat /proc/net/tcp on ppc64/ia64 for large hash tables because the rw locks 
> > are gone.
> 
> But spinlocks are in! Would that still improve the performance compared to rw 
> locks?  (See me earlier note where I have explained that lookup done for 
> /proc/net/tcp is _not_ lock-free yet).

Yes, spinlocks are much faster than rwlocks.

-Andi
