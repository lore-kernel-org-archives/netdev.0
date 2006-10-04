From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Customizable TCP backoff patch
Date: Wed, 4 Oct 2006 10:17:52 -0700
Message-ID: <20061004101752.4e42e2ff@freekitty>
References: <451AC889.5000407@redhat.com>
	<20060927.161638.62343616.davem@davemloft.net>
	<4522A88E.2070200@redhat.com>
	<20061004.000722.99203823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: woodard@redhat.com, netdev@vger.kernel.org, mgrondona@llnl.gov,
	behlendorf1@llnl.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17834 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161894AbWJDRSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 13:18:12 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061004.000722.99203823.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 04 Oct 2006 00:07:22 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Ben Woodard <woodard@redhat.com>
> Date: Tue, 03 Oct 2006 11:14:38 -0700
> 
> > > Other issues:
> > > 
> > > 1) 2 "u32" in the tcp_sock is a lot of space to devote to this
> > >    new state.  If it can fit in 2 "u16"'s or even less space,
> > >    please use that.
> > > 
> > > 2) the expression "(tp->foo ? : sysctl_foo)" is repeated many times
> > >    in the patch, please encapsulate it into an inline function
> > >    or similar
> > > 
> > 
> > How does this look to you for answering your two complaints above.
> 
> It looks a lot better.  I'd like you to take #2 further,
> put the inline function into net/tcp.h and use it in the
> tcp.c instances too.
> 
> Also, please don't format code like this:
> 
> +static inline __u16 rto_max(struct tcp_sock *tp){
> +        return tp->rto_max ? : sysctl_tcp_rto_max;
> +}
> +
> +static inline __u16 rto_init(struct tcp_sock *tp){
> +        return tp->rto_init ? : sysctl_tcp_rto_init;
> +}
> 
> The openning brace of each functions belongs on a line by itself,
> thanks.
> 
> Finally, I'm not so sure "seconds" is the best unit for the
> socket option.  In fact you use "seconds" as the unit for
> the socket option and the sysctl is raw jiffies.  That's
> inconsistency is really problematic.
> 
> At the very least, seconds might not be fine enough granularity
> for some circumstances.  Heck, the default RTO_MIN is 1/5 of a
> second. :-)
> 
> I also understand that going to milliseconds or microseconds would
> make the size of the in-socket struct members an issue again.  These
> things are never easy are they? :-/
> 
> Any better ideas?

If you are willing to do a little more work, the sysctl value can be
in milliseconds, and the internal socket member in some other unit
like jiffies.  It does require writing your own in/out translation
instead of using proc_dointvec

-- 
Stephen Hemminger <shemminger@osdl.org>
