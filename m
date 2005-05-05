From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] textsearch infrastructure + skb_find_text()
Date: Thu, 5 May 2005 19:42:24 +0200
Message-ID: <20050505174224.GB25977@postel.suug.ch>
References: <20050504234036.GH18452@postel.suug.ch> <427A51A2.8090600@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <427A51A2.8090600@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Pablo Neira <427A51A2.8090600@eurodev.net> 2005-05-05 19:02
> - A custom destroy function in ts_ops.

Sure, can be added once we need it. Currently none of my
algorithms allocate anything on their own. Might be worth
to change the API and replace textsearch_put with textesearch_destroy
also freeing the configuration though.

> - I don't see a way to look for matches in fragments. I mean, say we've 
> got "dancing " in a fragment and "chicken" in the next one. Currently we 
> don't get a match.

This is implemented in skb_find_text(), I just looked through rusty's
code and it's very simliar so we could make the args in ts_state a
union of long args[6] and char cb[XXX] so we can store skb_iter
in there.

> I've been reworking the framework for string matching that I sent you 
> two/three months ago, you've definitely worked on a good base. Since 
> then I've introduced a lot of changes and actually I've been testing it 
> (ick, that means that we've clashed!).

I don't think so, my approach is quite different and allows for
optimized text searches over fragments, multiple skbs, etc without
any hacks around the fragment borders. It's a lot more generic
allowing it to be in lib/ so it can be used from other subsystem
as well.

> I think that I can merge both works and then roll on. I still need more 
> time to study more in deep your proposition.

Sure go ahead but please don't merge it into netfilter, a) the core
really is supposed to be in lib, and b) I don't want any netfilter
dependencies in my ematches.
