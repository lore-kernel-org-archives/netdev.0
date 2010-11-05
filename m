From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 46/49] net/netfilter: Use vzalloc
Date: Thu, 04 Nov 2010 23:55:46 -0700
Message-ID: <1288940146.18440.55.camel@Joe-Laptop>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
	 <7d6da34b7e84955795717b0241000a0701cd5b34.1288925425.git.joe@perches.com>
	 <1288938640.3234.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Juhl <jj@chaosbits.net>, Jiri Kosina <trivial@kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1288938640.3234.12.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-11-05 at 07:30 +0100, Eric Dumazet wrote:
> I had _one_ patch, waiting that David actually had vzalloc() in its tree
> before sending it.

Fine by me, use yours.

> Given Jesper Juhl was doing this work, could you please take another
> one, please ?
> For example, explaining him how to use other tools than "bash+egrep
> +manual inspection" as he mentioned in a previous mail.

Jesper Juhl was both pointed at the cocci docs and
given a cocci script.  He said he'd investigate it
when he could.  I trust he will get to it.

I think that for this sort of patchset, grep and
manual inspection works just as well as spatch
and likely better because a simple cocci script
doesn't transform code like:

	if (size > PAGE_SIZE)
		ptr = vmalloc(size);
	else
		ptr = kmalloc(size, GFP);
	if (ptr)
		memset(ptr, 0, size);

I did say in the 00 cover that this was broken up
just to cc the maintainers of each block.

I also think a single rolled-up single patch is good.

I believe Jiri Kosina can easily apply all these
individual patches as a single patch if he chooses.

