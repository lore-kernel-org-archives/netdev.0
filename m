From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Thu, 12 Feb 2004 11:46:37 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402121116050.1399@u.domain.uli>
References: <Pine.LNX.4.44.0402111534310.2809-100000@l>
 <1076561326.1032.62.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1076561326.1032.62.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 11 Feb 2004, jamal wrote:

> > 	It looks bad to call route_slow for every one request,
> > I have to think more about it.
>
> If you make another get it goes via fast path.
> The disappointing part is this feature has a lot of potential
> if it works "correctly" (imagine being able to populate route cache
> before packet arrives and not needing for packet to go via slow path).

	I'm not sure I understand your idea, may be you will try
it one day :)

> > - this cycle repeats on each 3 seconds which means that for 1
> > second we queue requests and for 2 seconds we just drop
>
> I am indifferent about the above (and it may be complicating things).

	I'll have to test it first because it can reduce the
proxy_queue usage up to 3 times which can be desired in some
setups, we have linear search there.

> Ok, remove the flag. That one piece is safe. I didnt understand
> why you have to speacial case for "NAT/fwd/pneigh"

	DNAT is like local address, no need to delay at all.

> I think we have been this whole issue severely (i.e you understand my
> view and i understand yours) - lets get a closure. Heres where i stand:
> - checking validity in fast response is fair game and doesnt need a flag
> - loops must be avoided
>
> Some of your features are fine except they may be a little extreme.
> Note, this code has been to work well for years, the minimalist
> approach to features would be the best approach.

	I hope it will continue to work but in a fair way :)

	ok, we are the final of this, I have prepared a change log:

http://www.ssi.bg/~ja/tmp/CHANGES

	At this point I do not know how to optimize this patch and
all changes look valid to me. arp_proxy-2.6.2-1.diff is still the
latest version but I have to check the proxy_queue optimization.
To make the code more readable may we can move the (IN_DEV_FORWARD(in_dev))
body at the end of arp_process. And I'll do more tests in the following
days.

	I know you prefer to live with the old behaviour. I'm not
sure if we reorder the old code it will look more readable while
supporting the main new features. And I'm not going to push this if
we do not have consensus on the implementation. Let me know if
you have a better version of this change.

> cheers,
> jamal

Regards

--
Julian Anastasov <ja@ssi.bg>
