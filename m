From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] textsearch infrastructure + skb_find_text()
Date: Sun, 8 May 2005 13:45:39 +0200
Message-ID: <20050508114539.GP28419@postel.suug.ch>
References: <20050504234036.GH18452@postel.suug.ch> <427A51A2.8090600@eurodev.net> <20050505174224.GB25977@postel.suug.ch> <427AC96E.2020208@eurodev.net> <20050506123639.GE28419@postel.suug.ch> <1115384649.7660.140.camel@localhost.localdomain> <20050506144308.GF28419@postel.suug.ch> <1115470985.19561.58.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Pablo Neira <pablo@eurodev.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi Salim <hadi@znyx.com>
Content-Disposition: inline
In-Reply-To: <1115470985.19561.58.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Jamal Hadi Salim <1115470985.19561.58.camel@localhost.localdomain> 2005-05-07 09:03
> On Fri, 2005-06-05 at 16:43 +0200, Thomas Graf wrote:
> 
> > As you can see, it expects a char * in args[0] and the length of it
> > in args[1]. All it does is check whether all bytes have been read
> > already and if not return the remaining part of the buffer so even
> > if the search algorithm can't consume all the bytes returned it will
> > still work as expected.
> > 
> 
> Ok, makes sense - in the case of a string spanning multi skbs, i suppose
> it wouldnt matter, correct?

Strings spanning multiple skbs can be handled just like a paged skbs
_iff_ all skbs are known at the point the search starts, otherwise
we'll need more trickering.

> Sorry - I thought you were talking about pre-fetching text as in
> lookahead for text in a regexp state machine.
> I am not sure i see the L1 cache connection. Both seem to have tight for
> loops and depending on the algorithm there would be no difference
> in cache warmth afaics. Infact your scheme may suffer more because it
> has a lot of stuff on the stack. However, playing around with the code
> is the only way to find out.

You're probably right, I suspect mine to perform better because in a
typical search there is less work to do per loop and the interruption
to fetch the next block of text is less intrusive. Time will tell.
