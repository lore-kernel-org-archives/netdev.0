From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 18/24] sctp: Remove unnecessary OOM logging messages
Date: Wed, 31 Aug 2011 17:25:11 -0700
Message-ID: <1314836711.27632.34.camel@Joe-Laptop>
References: <21b4d996c8861373ac77d427914ec7882fe0c83e.1314650069.git.joe@perches.com>
	 <1314654209.2563.7.camel@edumazet-laptop>
	 <1314654681.2563.10.camel@edumazet-laptop>
	 <20110829.181520.933815499847625814.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, vladislav.yasevich@hp.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110829.181520.933815499847625814.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-08-29 at 18:15 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 29 Aug 2011 23:51:21 +0200
> > Le lundi 29 ao=C3=BBt 2011 =C3=A0 23:43 +0200, Eric Dumazet a =C3=A9=
crit :
> >> Furthermore, a failed vmalloc() is not guaranteed to emit an OOM
> >> message, is it ?
> > It currently displays a message without context :
> > vmap allocation for size XXXXXX failed: use vmalloc=3D<size> to inc=
rease
> > size.
> > So we dont know which part of the kernel asked this allocation.
> > Please dont remove existing error messages after failed vmalloc() c=
alls.
> Indeed.
> Joe, these vmalloc() and also the __GFP_NOWARN cases will need to be
> attended to and this series resubmitted as such.

No worries.

Andrew Morton picked up a patch I posted that
changes vmalloc to be similar to kmalloc when
the pointer returned is NULL (OOM).  It now
uses dump_stack for those cases.

https://patchwork.kernel.org/patch/1114682/

I'll keep all the current vmalloc failure messages
for now and resubmit in a day or two this series
with acks.  Not batman or netfilter though as they
were picked up by their maintainers.

A month or two after the vmalloc patch hits
mainline and/or wider testing, and it's deemed
acceptable, removing vmalloc site specific OOM
messages should be appropriate.

Anyone object?

I plan on submitting drivers/net OOM removals
next week.
