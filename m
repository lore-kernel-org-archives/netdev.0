From: jamal <hadi@cyberus.ca>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: 12 Feb 2004 09:21:47 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076595707.1024.25.camel@jzny.localdomain>
References: <Pine.LNX.4.44.0402111534310.2809-100000@l>
	 <1076561326.1032.62.camel@jzny.localdomain>
	 <Pine.LNX.4.58.0402121116050.1399@u.domain.uli>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402121116050.1399@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Julian,

On Thu, 2004-02-12 at 04:46, Julian Anastasov wrote:

> > If you make another get it goes via fast path.
> > The disappointing part is this feature has a lot of potential
> > if it works "correctly" (imagine being able to populate route cache
> > before packet arrives and not needing for packet to go via slow path).
> 
> 	I'm not sure I understand your idea, may be you will try
> it one day :)

We can take this offline. 

> > I am indifferent about the above (and it may be complicating things).
> 
> 	I'll have to test it first because it can reduce the
> proxy_queue usage up to 3 times which can be desired in some
> setups, we have linear search there.

That would be great. If you can show a claer benefit, should be fine.


> > Some of your features are fine except they may be a little extreme.
> > Note, this code has been to work well for years, the minimalist
> > approach to features would be the best approach.
> 
> 	I hope it will continue to work but in a fair way :)

Thats what i am hoping for. Sometimes i just dont touch code
unnecessarily because it may have strange side effects; look at that
tunnel problem posted yesterday for example - some change an inequality
sign in the net sched code and ipip tunnels get affected.

> 	ok, we are the final of this, I have prepared a change log:
> 
> http://www.ssi.bg/~ja/tmp/CHANGES
> 
> 	At this point I do not know how to optimize this patch and
> all changes look valid to me. arp_proxy-2.6.2-1.diff is still the
> latest version but I have to check the proxy_queue optimization.
> To make the code more readable may we can move the (IN_DEV_FORWARD(in_dev))
> body at the end of arp_process. And I'll do more tests in the following
> days.
> 
> 	I know you prefer to live with the old behaviour. I'm not
> sure if we reorder the old code it will look more readable while
> supporting the main new features. And I'm not going to push this if
> we do not have consensus on the implementation. Let me know if
> you have a better version of this change.
> 

Post the patch and i will test it in my environment and make sure it
doesnt break anything here. My interest are two cases: default setup and
proxy_delay being 0. 

cheers,
jamal
