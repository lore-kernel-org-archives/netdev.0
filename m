From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] checkpatch: Add --strict preference for #defines using
 BIT(foo)
Date: Mon, 10 Nov 2014 15:36:47 -0800
Message-ID: <20141110153647.f98f7d60fa24bf3bf7cbc215@linux-foundation.org>
References: <1415265610-9338-1-git-send-email-jiri@resnulli.us>
	<1415265610-9338-10-git-send-email-jiri@resnulli.us>
	<20141107.151607.480474516800359791.davem@davemloft.net>
	<1415394939.23530.20.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415394939.23530.20.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 07 Nov 2014 13:15:39 -0800 Joe Perches <joe@perches.com> wrote:

> Using BIT(foo) and BIT_ULL(bar) is more common now.
> Suggest using these macros over #defines with 1<<value.

urgh.  I'm counting eightish implementations of BIT(), an unknown
number of which are actually being used.  Many use 1<<n, some use
1UL<<N, another uses 1ULL<<n.  I'm a bit reluctant to recommend that
anyone should use BIT() until it has has some vigorous scrubbing :(

Is it actually an improvement?  If I see

#define X	(1U << 7)

then I know exactly what it does.  Whereas when I see

#define X	BIT(7)

I know neither the size or the signedness of X so I have to go look it
up.


I have no strong feelings either way, but I'm wondering what might have
inspired this change?
