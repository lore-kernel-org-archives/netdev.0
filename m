From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] Limit the size of the IPV4 route hash.
Date: Fri, 10 Dec 2004 13:06:34 -0800
Message-ID: <20041210130634.251c46f9.davem@davemloft.net>
References: <20041210190025.GA21116@lnx-holt.americas.sgi.com>
	<20041210114829.034e02eb.davem@davemloft.net>
	<20041210210006.GB23222@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: holt@sgi.com, yoshfuji@linux-ipv6.org, akpm@osdl.org,
        hirofumi@parknet.co.jp, torvalds@osdl.org, dipankar@ibm.com,
        laforge@gnumonks.org, bunk@stusta.de, herbert@apana.org.au,
        paulmck@ibm.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        gnb@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robin Holt <holt@sgi.com>
In-Reply-To: <20041210210006.GB23222@lnx-holt.americas.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Dec 2004 15:00:06 -0600
Robin Holt <holt@sgi.com> wrote:

> > Also, 1 page even in your case is (assuming you are on a 64-bit platform,
> > you didn't mention) going to give us 1024 hash chains.  A reasonably
> > busy web server will easily be talking to more than 1K unique hosts at
> > a given point in time.  This is especially true as slow long distance
> > connections bunch up.
> 
> But 1k hosts is not the limit with a 16k page.  There are 1k buckets,
> but each is a list.  A reasonably well designed hash will scale to greater
> than one item per bucket.  Additionally, for the small percentage of web
> servers with enough network traffic that they will be affected by the
> depth of the entries, they can set rhash_entries for their specific needs.

We want to aim for a depth of 1 in each chain, so that, assuming the
hash is decent, we'll achieve O(1) lookup complexity.  That is why we
want the number of chains to be at least as large as the number of
active routing cache entries we'll work with.

> I realize I have a special case which highlighted the problem.  My case
> shows that not putting an upper limit or at least a drastically aggressive
> non-linear growth cap does cause issues.  For the really large system,
> we were seeing a size of 512MB for the hash which was limited because
> that was the largest amount of memory available on a single node.

That's true, 512MB is just too much.  So let's define some reasonable
default cap like 16MB or 32MB, and as current it is overridable via
rhash_entries.
