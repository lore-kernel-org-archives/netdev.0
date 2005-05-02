From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost
Date: Tue, 03 May 2005 01:00:54 +0200
Message-ID: <4276B126.6020704@tpack.net>
References: <E1DQlsn-0005yd-00@gondolin.me.apana.org.au> <426FDF8B.1030808@tpack.net> <20050427214224.GA25325@gondor.apana.org.au> <42701FFD.5000505@tpack.net> <20050427234359.GB22238@gondor.apana.org.au> <1114768308.4695.1487.camel@tsc-6.cph.tpack.net> <20050429101836.GA2237@gondor.apana.org.au> <1114777355.4695.1598.camel@tsc-6.cph.tpack.net> <20050429234512.GA22699@gondor.apana.org.au> <427380A8.2070006@tpack.net> <20050501081140.GA20647@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050501081140.GA20647@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Sat, Apr 30, 2005 at 02:57:12PM +0200, Tommy Christensen wrote:
>>So, I am reluctant to drop this check for netif_queue_stopped. Doing so
>>would needlessly impact the drivers that work fine already (or at least
>>should be handling this situation).
> 
> I don't see how those drivers are worse off without this check.  When
> the carrier is off it doesn't really matter whether we're sending them
> packets or not.  Besides, you didn't put this check in the link_watch
> code path which would affect them a lot more than this path.

My reasoning is reversed. You're saying:
   "What could possibly happen, if we do this?",
whereas I'm saying:
   "This has no benefit, so why risk it?".

I'm just not confident that some odd driver won't choke on this change.

As I'm probably just being too cautious (and your approach does seem
more consistent), I'm sending a new patch following your ideas.
And then Dave has something to choose from ;-)

>>Ideas, anyone?
> 
> You mean how we can avoid the double call? Here is one way.  Move
> the setting of IF_RUNNING out of dev_get_flags and into dev_activate.
> This would guarantee that IF_RUNNING is set iff the device has a qdisc.
> Assuming that you remove the aformentioned netif_queue_stopped check,
> the device has a qdisc iff the carrier is on.  So this preserves the
> meaning of IF_RUNNING.
> 
> Now you can avoid the double call by returning early in dev_activate if
> IF_RUNNING is set, and in dev_deactivate if IF_RUNNING is not set.

Implemented in the new patch, thanks.


-Tommy
