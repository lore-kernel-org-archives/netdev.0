From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Customizable TCP backoff patch
Date: Wed, 27 Sep 2006 16:16:38 -0700 (PDT)
Message-ID: <20060927.161638.62343616.davem@davemloft.net>
References: <451AC889.5000407@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mgrondona@llnl.gov, behlendorf1@llnl.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10946
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031240AbWI0XQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 19:16:40 -0400
To: woodard@redhat.com
In-Reply-To: <451AC889.5000407@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Woodard <woodard@redhat.com>
Date: Wed, 27 Sep 2006 11:52:57 -0700

> Because these are general utility clusters we run many different 
> programs and so trying to fix this problem in the application is not 
> possible since there are literally hundreds if not thousands of them.

Then why add a socket option setting as your patch does? :-)

I also object to the socket option setting being allowed for
any user because this can have awful effects if allowed by
arbitrary users on arbitrary networks.

> We're more than willing to consider other approaches to handling this
> particular workload better.  We've even considered that TCP isn't at all 
> the right protocol but this affects several protocols including NFS and 
> the benefits of running NFS over TCP are too great.
> 
> The original patch was prepared by Brian Behlendorf. He asked me to 
> adapt it for current kernels keep it up to date and send upstream.
> 
> This may also help people like Andrew Athan which reported a similar 
> problem a couple of days ago on the linux-net mailing list: 
> http://www.uwsg.iu.edu/hypermail/linux/net/0609.3/0005.html I suspect 
> that it is more common a case than is widely recognized.
> 
> Signed-off-by: Ben Woodard <woodard@redhat.com>
> Signed-off-by: Brian Behlendorf <behlendorf1@llnl.gov>

Other issues:

1) 2 "u32" in the tcp_sock is a lot of space to devote to this
   new state.  If it can fit in 2 "u16"'s or even less space,
   please use that.

2) the expression "(tp->foo ? : sysctl_foo)" is repeated many times
   in the patch, please encapsulate it into an inline function
   or similar

I'm still torn on the fundamental issues of this patch.  I think
random backoff is a better generic solution to this kind of problem.
If it works for ethernet, it might just work for TCP too :-)

Thanks.
