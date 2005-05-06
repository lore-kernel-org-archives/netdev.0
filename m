From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] textsearch infrastructure + skb_find_text()
Date: Fri, 06 May 2005 09:04:08 -0400
Message-ID: <1115384649.7660.140.camel@localhost.localdomain>
References: <20050504234036.GH18452@postel.suug.ch>
	 <427A51A2.8090600@eurodev.net> <20050505174224.GB25977@postel.suug.ch>
	 <427AC96E.2020208@eurodev.net>  <20050506123639.GE28419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050506123639.GE28419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-06-05 at 14:36 +0200, Thomas Graf wrote:
[..]

> function find-text(pattern)
>   foreach text-segment do
>     call search-bm(text-segment, pattern);
>   done
> end
> 
> This is what most people naturally think of when dealing with this
> problem and it might be sufficient for many situations, however it
> requires the searching algorithm to store its state in some persistent
> memory which can be troublesome depending on the volume of these
> variables.
> 

[..]

I dont see any difference between the two in terms of state storage.
Can you really avoid storing state? Can you give an example?

> Why? Because it dramatically simplifies the searching algorithms
> since they can decide when to fetch the next block which is
> absolutely essential for cases like regular expression where the
> state machine gets quite complex and a single entry point

The other scheme is to have the callback return a code which says
"get me more text" or " enough/done" in which case the state machine for
the search alg is no different in both cases.

>  (i.e.
> leaving the function and enter it again with new data) would make
> things much more complex. Minor advantages are a) the get_text()
> implementation is usually quite small and will hopefully not mess
> up the cacheline optimizations of the actual searching loop 

It depends on the search algorithm - if it is small, you benefit from
either scheme. If it is large, you loose in both.
 
> and
> b) it allows the searching algorithm to do prefetching.
> 

I am trying to sink this in; prefetching would be valuable for regexp,
but why would the other scheme not be able to do it? 

> << coffee break >>
> 

I have to run to work while you get coffee ;->
I will read the rest later.

cheers,
jamal
