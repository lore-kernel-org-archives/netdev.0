From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] string matching ematch
Date: Thu, 27 Jan 2005 21:51:47 +0100
Message-ID: <20050127205147.GS31837@postel.suug.ch>
References: <20050126150714.GL31837@postel.suug.ch> <41F94C63.7010800@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <41F94C63.7010800@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Pablo Neira <41F94C63.7010800@eurodev.net> 2005-01-27 21:17
> Thomas Graf wrote:
> 
> >I'd like to discuss the string matching ematch, I don't care about the
> >algorithm used but rather whether to make it stateful, match over
> >fragments, etc. I attached a simple stateless string matching ematch
> >using the Knuth-Morris-Pratt algorithm as a starting point.
> > 
> 
> I've posted something similar after christmas in netfilter-devel[1]. 
> It's fragment aware, actually my implementation uses boyer-moore to look 
> for matches in the payload, and it uses brute force together with 
> Rusty's skb_iter stuff to look for matches on the edges.

I've seen it but sticked to KMP because it uses less memory. Their
searching phase time complexity is nearly equal around O(nm) for
n being the length of T[] and m being the length of P[]. BM
definitely has a better performance for highly periodic P[]'s in a
periodic T[] though.

I'm missing a few things in your string matching API, namely
the ability to define a upper limit of the searching range which
can give much better performance gains than the best optimization
can do. A naive searching method around the borders of fragments
is definiltey easier but even there you could benefit from ruling
out invalid shifts.

> The worst case is not that bad for small patterns.

I don't think that any of the algorithms really make a difference,
theoretically yes but what we're basically should be looking for
is one with good average performance by detecting unnecessary
shifts. Our T[] is limited by the skb as long as we're not going
into statefull searches and thus other resources matter more to me
than a few more cycles.

> I'll give it more spins these days since I've got some spare time. I'll 
> also have a look at your work. I think that we could join efforts and 
> push something good, thoughts?

Definitely, being able to specify the upper limit is a must for me
though. Another difference is that I compute the prefix table in
userspace.
