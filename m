From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] string matching ematch
Date: 31 Jan 2005 08:59:54 -0500
Message-ID: <1107179994.7840.164.camel@jzny.localdomain>
References: <20050126150714.GL31837@postel.suug.ch>
	 <41F94C63.7010800@eurodev.net>  <20050127205147.GS31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050127205147.GS31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Reading email backward ..

I think we should allow for all sorts of algrithms KMP, Boyer-Moore etc
to be plugged in (in tc this is already there).
The stuff that Harald was looking at (at least around July when i last
talked to him on this) is an infrastructure level thing. Its derived
from someone who seems to have well thought of the callbacks etc for a
good stateful solution. I cant remember the person from whom Harald was
deriving his stuff (email was somewhere in .fr) - but it did seem pretty
sensible. If we can have infrastructure that is also usable by tc, that
would be great so we dont go cutnpasting unnecessarily.

Having said all that:
Thomas, I think you should leave what you have as totaly stateless
unless we dont have a shareable solution. I have tons of ideas i could
share when we get to that level.

cheers,
jamal

On Thu, 2005-01-27 at 15:51, Thomas Graf wrote:
> * Pablo Neira <41F94C63.7010800@eurodev.net> 2005-01-27 21:17
> > Thomas Graf wrote:
> > 
> > >I'd like to discuss the string matching ematch, I don't care about the
> > >algorithm used but rather whether to make it stateful, match over
> > >fragments, etc. I attached a simple stateless string matching ematch
> > >using the Knuth-Morris-Pratt algorithm as a starting point.
> > > 
> > 
> > I've posted something similar after christmas in netfilter-devel[1]. 
> > It's fragment aware, actually my implementation uses boyer-moore to look 
> > for matches in the payload, and it uses brute force together with 
> > Rusty's skb_iter stuff to look for matches on the edges.
> 
> I've seen it but sticked to KMP because it uses less memory. Their
> searching phase time complexity is nearly equal around O(nm) for
> n being the length of T[] and m being the length of P[]. BM
> definitely has a better performance for highly periodic P[]'s in a
> periodic T[] though.
> 
> I'm missing a few things in your string matching API, namely
> the ability to define a upper limit of the searching range which
> can give much better performance gains than the best optimization
> can do. A naive searching method around the borders of fragments
> is definiltey easier but even there you could benefit from ruling
> out invalid shifts.
> 
> > The worst case is not that bad for small patterns.
> 
> I don't think that any of the algorithms really make a difference,
> theoretically yes but what we're basically should be looking for
> is one with good average performance by detecting unnecessary
> shifts. Our T[] is limited by the skb as long as we're not going
> into statefull searches and thus other resources matter more to me
> than a few more cycles.
> 
> > I'll give it more spins these days since I've got some spare time. I'll 
> > also have a look at your work. I think that we could join efforts and 
> > push something good, thoughts?
> 
> Definitely, being able to specify the upper limit is a must for me
> though. Another difference is that I compute the prefix table in
> userspace.
> 
> 
