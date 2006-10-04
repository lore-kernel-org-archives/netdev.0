From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Customizable TCP backoff patch
Date: Wed, 04 Oct 2006 00:07:22 -0700 (PDT)
Message-ID: <20061004.000722.99203823.davem@davemloft.net>
References: <451AC889.5000407@redhat.com>
	<20060927.161638.62343616.davem@davemloft.net>
	<4522A88E.2070200@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mgrondona@llnl.gov, behlendorf1@llnl.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36506
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932396AbWJDHHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 03:07:18 -0400
To: woodard@redhat.com
In-Reply-To: <4522A88E.2070200@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Woodard <woodard@redhat.com>
Date: Tue, 03 Oct 2006 11:14:38 -0700

> > Other issues:
> > 
> > 1) 2 "u32" in the tcp_sock is a lot of space to devote to this
> >    new state.  If it can fit in 2 "u16"'s or even less space,
> >    please use that.
> > 
> > 2) the expression "(tp->foo ? : sysctl_foo)" is repeated many times
> >    in the patch, please encapsulate it into an inline function
> >    or similar
> > 
> 
> How does this look to you for answering your two complaints above.

It looks a lot better.  I'd like you to take #2 further,
put the inline function into net/tcp.h and use it in the
tcp.c instances too.

Also, please don't format code like this:

+static inline __u16 rto_max(struct tcp_sock *tp){
+        return tp->rto_max ? : sysctl_tcp_rto_max;
+}
+
+static inline __u16 rto_init(struct tcp_sock *tp){
+        return tp->rto_init ? : sysctl_tcp_rto_init;
+}

The openning brace of each functions belongs on a line by itself,
thanks.

Finally, I'm not so sure "seconds" is the best unit for the
socket option.  In fact you use "seconds" as the unit for
the socket option and the sysctl is raw jiffies.  That's
inconsistency is really problematic.

At the very least, seconds might not be fine enough granularity
for some circumstances.  Heck, the default RTO_MIN is 1/5 of a
second. :-)

I also understand that going to milliseconds or microseconds would
make the size of the in-socket struct members an issue again.  These
things are never easy are they? :-/

Any better ideas?
