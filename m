From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.4] backport neighbour cache redesign
Date: Mon, 4 Oct 2004 14:16:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004141651.153ec066.davem@davemloft.net>
References: <20040930154753.GD1860@sunbeam.de.gnumonks.org>
	<20041004121759.26798f1d.davem@davemloft.net>
	<20041004201525.GF27499@sunbeam.de.gnumonks.org>
	<20041004132034.00cfe23c.davem@davemloft.net>
	<20041004211158.GG27499@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20041004211158.GG27499@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 4 Oct 2004 23:11:58 +0200
Harald Welte <laforge@gnumonks.org> wrote:

> yes, I remember that email.  I didn't think further about it, since I
> got the feeling that there is significant movement to get rid of the
> neighbour cache at some point (if/when there is some fast lookup
> algorithm implemented) - and if we look at ipv6, there is no routing
> cache.

Another idea is to dynamically grow the thresholds based upon usage
just as we do for the hash tables.  For example, if we find say %90
of neighbour entries in-use at forced GC time, we increment the
thresholds by some factor.

Note that the "in-use" part is very important, it prevents a DoS
spam from growing the neighbour cache since such traffic causes
neighbour entries to quickly become unused.
