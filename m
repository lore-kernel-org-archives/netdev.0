From: Andrew Morton <akpm@osdl.org>
Subject: Re: [IPV4] Fix ip_rt_gc_min_interval_ms procfs/sysctl
Date: Fri, 18 Feb 2005 02:49:17 -0800
Message-ID: <20050218024917.2e5c19ec.akpm@osdl.org>
References: <20050218.192430.98634850.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: torvalds@osdl.org, davem@davemloft.net, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
In-Reply-To: <20050218.192430.98634850.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ____________ <yoshfuji@linux-ipv6.org> wrote:
>
> Recently, we added gc_min_interval_ms procfs/sysctl.
> 
>  Because type of ip_rt_gc_min_interval is int, 
>  use of ulong helpers is inappropriate and unsafe.
>  I believe it breaks some archs that the size of unsigned long
>  is not equal to one of int.
> 
>  So, let's add new sysctl helpers and use them instead.
>  This also fixes inconsistency between procfs and sysctl.

I disagree.  ip_rt_gc_min_interval is an `int' and does not need to be
changed to `long' - note how is is always used as a time delta.

So the current code works OK.  However it is rather poor design, because it
exposes the value of jiffies to userspace.  So the user and his scripts
need to know what the machine's current HZ value is to set this tunable
sanely.

A better approach wold be to rework ip_rt_gc_min_interval so that its
userspace-visible units are milliseconds.
