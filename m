From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [IPV4] Fix ip_rt_gc_min_interval_ms procfs/sysctl
Date: Fri, 18 Feb 2005 19:59:13 +0900 (JST)
Message-ID: <20050218.195913.07287814.yoshfuji@linux-ipv6.org>
References: <20050218.192430.98634850.yoshfuji@linux-ipv6.org>
	<20050218024917.2e5c19ec.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, davem@davemloft.net, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
To: akpm@osdl.org
In-Reply-To: <20050218024917.2e5c19ec.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050218024917.2e5c19ec.akpm@osdl.org> (at Fri, 18 Feb 2005 02:49:17 -0800), Andrew Morton <akpm@osdl.org> says:

> YOSHIFUJI Hideaki / ____________ <yoshfuji@linux-ipv6.org> wrote:
> >
> > Recently, we added gc_min_interval_ms procfs/sysctl.
> > 
> >  Because type of ip_rt_gc_min_interval is int, 
> >  use of ulong helpers is inappropriate and unsafe.
> >  I believe it breaks some archs that the size of unsigned long
> >  is not equal to one of int.
> > 
> >  So, let's add new sysctl helpers and use them instead.
> >  This also fixes inconsistency between procfs and sysctl.
> 
> I disagree.  ip_rt_gc_min_interval is an `int' and does not need to be
> changed to `long' - note how is is always used as a time delta.

I'm not suggesting to use ulong helpers.

The type of variable (ip_rt_gc_min_interval) is int,
and we erroneously started using ulong helpers for it.
This break memory.

So, I suggest to use appropriate helpers.

> A better approach wold be to rework ip_rt_gc_min_interval so that its
> userspace-visible units are milliseconds.

My patch add a sysctl/procfs helpers to convert units
between milliseconds and jiffies.

Do you still disagree?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
