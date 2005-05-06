From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [RFC] textsearch infrastructure + skb_find_text()
Date: Fri, 06 May 2005 03:33:34 +0200
Message-ID: <427AC96E.2020208@eurodev.net>
References: <20050504234036.GH18452@postel.suug.ch> <427A51A2.8090600@eurodev.net> <20050505174224.GB25977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050505174224.GB25977@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Pablo Neira <427A51A2.8090600@eurodev.net> 2005-05-05 19:02
> 
>>- A custom destroy function in ts_ops.
> 
> 
> Sure, can be added once we need it. Currently none of my
> algorithms allocate anything on their own. Might be worth
> to change the API and replace textsearch_put with textesearch_destroy
> also freeing the configuration though.

that's fine

>>- I don't see a way to look for matches in fragments. I mean, say we've 
>>got "dancing " in a fragment and "chicken" in the next one. Currently we 
>>don't get a match.
> 
> 
> This is implemented in skb_find_text(), I just looked through rusty's
> code and it's very simliar so we could make the args in ts_state a
> union of long args[6] and char cb[XXX] so we can store skb_iter
> in there.

Yes, we could just use one of those args in ts_state to store if we 
found a partial match or not.

>>I've been reworking the framework for string matching that I sent you 
>>two/three months ago, you've definitely worked on a good base. Since 
>>then I've introduced a lot of changes and actually I've been testing it 
>>(ick, that means that we've clashed!).
> 
> 
> I don't think so, my approach is quite different and allows for
> optimized text searches over fragments, multiple skbs, etc without
> any hacks around the fragment borders.

Boyer-Moore requires such hack to look for matches around the fragment 
borders. But no problem, such hack will go inside the bm_find function.

> It's a lot more generic
> allowing it to be in lib/ so it can be used from other subsystem
> as well.

Sure, your approach is definitely more generic because I just thought 
about using such string matching framework for net apps, it's different 
from that point of view, but I still see things that reminds me to my 
proposed framework, say that ts_state thing ;).

>>I think that I can merge both works and then roll on. I still need more 
>>time to study more in deep your proposition.
> 
> 
> Sure go ahead but please don't merge it into netfilter, a) the core
> really is supposed to be in lib, and b) I don't want any netfilter
> dependencies in my ematches.

No problem mate. Just curious about something, since this stuff will 
live under lib, what kind of applications in kernel space could use this 
string matching framework ? I bet that non-net kernel guys will surely 
ask about it ;->

I'll be back working on this stuff next week, expect some feedback.

--
Pablo
