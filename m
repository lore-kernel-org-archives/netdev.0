From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Wed, 22 Sep 2004 00:14:48 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922.001448.73843048.yoshfuji@linux-ipv6.org>
References: <20040920225140.GH1307@sunbeam.de.gnumonks.org>
	<Pine.LNX.4.44.0409211412580.1570-100000@netcore.fi>
	<20040921134918.GK1307@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@gnumonks.org
In-Reply-To: <20040921134918.GK1307@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040921134918.GK1307@sunbeam.de.gnumonks.org> (at Tue, 21 Sep 2004 15:49:18 +0200), Harald Welte <laforge@gnumonks.org> says:

> > The situation with IPv6 is not much different than with IPv4.
> 
> I disagree (see below).

agreed (to harald).

> > It's worse in the sense that there is more space in each subnet for
> > doing aggressive probing -- but this may not be a big issue with a
> > good algorithm and a threshold.
> 
> So what is that 'good algorithm'.  The current Linux algorithm is from
> my point of view (only tested with ipv4) not very good when it comes to
> high numbers of neighbours.

Well, of course, we should limit number of total entries.

If we have enough memory for usual use,
we should not purge the "probably reachable" routes
(REACHABLE, STALE, DELAY, and PROBE) neighbours.
Probably, we should split neighbour entries to two parts.
 - INCOMPLETE
 - REACHABLE, STALE, DELAY and PROBE
Which means, we should NOT purge "known" entries by unknown entries.

If we don't have enough memory for usual use, hmm???
Probably (weighed) LFU.

--yoshfuji
