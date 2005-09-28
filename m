From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: rwlock recursion on CPU#0, netfilter related?
Date: Wed, 28 Sep 2005 17:58:15 +0300
Message-ID: <20050928145815.GA421@ee.oulu.fi>
References: <20050925105834.GA15243@ee.oulu.fi> <20050925134344.GJ731@sunbeam.de.gnumonks.org> <20050925201945.GA21176@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
Content-Disposition: inline
In-Reply-To: <20050925201945.GA21176@ee.oulu.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Sep 25, 2005 at 11:19:45PM +0300, Pekka Pietikainen wrote:
> Enabled, so this could be it. But 2.6.14-rc2-git4 did crash too (although
> it did take a bit longer for that to happen), and the changelog does state:
Ok, it looks like that patch was the thing after all. I now tried the latest
fedora-devel kernel (1.1582, based on 2.6.14-rc2-git6) and the box has been
running for a few hours happily. Could be the fedora kernel that claimed to
be git4 actually wasn't, or the git4 changelog was really a post-git4
changelog :). But anyway, bug is gone.

> > But only in 1 out of ten cases on average (when starting ping, ctrl+c,
> > pin, ctrl+c, ...).  I've always assumed it's some 64bit problem in
> > "ping" itself.
> Happens for all packets on the "broken" kernels, and works a-ok (few ms
> latencies to the same box) on the 2.6.13-era ones that don't crash.
> Could be a different bug, sure.
This one is still around, so it's a different bug. Looks like it's a 64-bit
issue, a 32-bit ping gives realistic ping times. tcpdump timestamps are also
affected, they're completely off too. So looks like someone broke packet
timestamps on 64-bit some time after 2.6.13.
