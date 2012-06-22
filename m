From: Debabrata Banerjee <dbavatar@gmail.com>
Subject: Re: Bug in net/ipv6/ip6_fib.c:fib6_dump_table()
Date: Fri, 22 Jun 2012 17:12:07 -0400
Message-ID: <CAATkVEyaocRcYJnfuQmGFAySBerQsXY44JDi4zjveP7TZNmu7Q@mail.gmail.com>
References: <CAATkVEzTxT6d5nzt_qwCuFWM-WcN8hdhjGxFRPXJ4=L35wKbGw@mail.gmail.com>
	<4FE37783.9000409@akamai.com>
	<1340310469.4604.6702.camel@edumazet-glaptop>
	<4FE41570.4090803@akamai.com>
	<1340353746.4604.9502.camel@edumazet-glaptop>
	<4FE476A6.1050209@akamai.com>
	<1340388785.4604.11442.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Josh Hunt <johunt@akamai.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"pekkas@netcore.fi" <pekkas@netcore.fi>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340388785.4604.11442.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 22, 2012 at 2:13 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2012-06-22 at 08:44 -0500, Josh Hunt wrote:
>
>> Ahh. That makes sense and is what Alexey said before I just didn't put
>> it all together. So we are OK reverting this patch? I cannot find a path
>> where the walker's pointers are updated without the tb6_lock write_lock.
>>
>
> There was a bug somewhere, not sure we want to NULL dereference again.
>

As you identified, the tree seems to be protected by tb6_lock. I
couldn't find a race by inspection either. If this is not the root of
the problem, how would this patch fix it? So I think it does nothing.
We are attempting to reproduce that crash to prove it, but like Gao
feng I don't think we will see it.

My current favorite theory is that inet6_dump_fib was called with a
NULL func in callback. This looks like the approximate area of the
crash, but it's impossible to say without more information from
Patrick McHardy.
