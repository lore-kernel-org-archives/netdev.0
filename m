From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Fri, 11 Oct 2002 00:23:21 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021011.002321.27802563.yoshfuji@linux-ipv6.org>
References: <20021006.033351.33728380.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0210101724030.9287-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0210101724030.9287-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0210101724030.9287-100000@netcore.fi> (at Thu, 10 Oct 2002 17:29:38 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> Dave, Alexey.. I think there has to be a high-level decision on how to
> proceed here.  I'm referring to the optimization.  TCP or other
> connection-oriented protocols use this one per connection; UDP and the
> like probably once per packet.  The latter is at least quite undesirable,
> as you pointed out.

Hmm, what we think is, performance critical applications such as DVTS
(Digital Video Transport System) will do bind(2) so the latter is not 
fatal problem.


We need improved source address selection for further feature(s)
(like privacy extentions).

Our code is easy to implement further rules and order of calculation
cost is same as before; O(n) while n is number of addresses.

We think netdev and/or usagi can develop optimization later,
and we think people can survive until then.


> Putting the stuff in the routing table could work, but then this algorithm
> would have to be re-run always when there are changes in any address in
> the node.  There might be other ways.

How about
 - store one (daddr,ddev,saddr,tstamp) set in sk
 - update addrconf_tstamp in addrconf_verify() (etc.)
 - check tstamp and addrconf_tstamp and use saddr if ok in saddr selection

--yoshfuji
