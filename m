From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: [RFC] textsearch infrastructure + skb_find_text()
Date: Sat, 07 May 2005 09:03:04 -0400
Message-ID: <1115470985.19561.58.camel@localhost.localdomain>
References: <20050504234036.GH18452@postel.suug.ch>
	 <427A51A2.8090600@eurodev.net> <20050505174224.GB25977@postel.suug.ch>
	 <427AC96E.2020208@eurodev.net> <20050506123639.GE28419@postel.suug.ch>
	 <1115384649.7660.140.camel@localhost.localdomain>
	 <20050506144308.GF28419@postel.suug.ch>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Pablo Neira <pablo@eurodev.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050506144308.GF28419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-06-05 at 16:43 +0200, Thomas Graf wrote:

> As you can see, it expects a char * in args[0] and the length of it
> in args[1]. All it does is check whether all bytes have been read
> already and if not return the remaining part of the buffer so even
> if the search algorithm can't consume all the bytes returned it will
> still work as expected.
> 

Ok, makes sense - in the case of a string spanning multi skbs, i suppose
it wouldnt matter, correct?

[..] 

> Not sure if this is clear out of context but maybe it gives you an idea
> why it is easier to maintain state of get_text() rather than the state
> of a whole searching algorithm.
> 

I got it. I suppose in the case of text contained within one skb this
would be an improvement (spanning across multi-skb should be no
difference; an improvemengt nonetheless)

> > 
> > I am trying to sink this in; prefetching would be valuable for regexp,
> > but why would the other scheme not be able to do it? 
> 
> I'm really not an expert on the validity of L1 caches and how to optimize
> it best but I believe that the less memory movement is in between the
> more likely prefetching helps? Both schemes involve a switch to another
> stack namespace but get_text() tends to be a lot smaller and less intrusive
> than a store & reload of a complex state machine. I really can't tell
> which is better regarding this subject without trying it out actually.
> 

Sorry - I thought you were talking about pre-fetching text as in
lookahead for text in a regexp state machine.
I am not sure i see the L1 cache connection. Both seem to have tight for
loops and depending on the algorithm there would be no difference
in cache warmth afaics. Infact your scheme may suffer more because it
has a lot of stuff on the stack. However, playing around with the code
is the only way to find out.

cheers,
jamal
