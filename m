From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [RFC] textsearch infrastructure et al v2
Date: Sat, 28 May 2005 14:56:37 +0200
Message-ID: <42986A85.9060001@eurodev.net>
References: <20050527224725.GG15391@postel.suug.ch> <1117281581.6251.68.camel@localhost.localdomain> <20050528123542.GR15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050528123542.GR15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * jamal <1117281581.6251.68.camel@localhost.localdomain> 2005-05-28 07:59
> 
>>I dont have  opinions on this since you and Pablo seem to agree on it.

to be frank, i'm still willing to propose some changes to Thomas, I'll 
do soon since he's pulled my ear with this second rfc request ;).

>>What I remember is that libssearch (or whatever that thing Harald was
>>looking at) did it differently (callback invoked and it return a code
>>which said to continue or not).
> 
> 
> Same for my infrastructure with the difference that libqsearch uses
> a single input buffer so no chance for non-linear data.

hm, i don't understand quite well, i bet that libqsearch was already 
fragment-aware. Anyway the main difference is that libqsearch wasn't 
designed to be used in user space so, for example, it needed a complete 
rework to reduce dynamic memory allocations.

>>Also the design should (I think you do already, just double checking) -
>>should be wary of optimizing for a specific algorithmn; i see you have
>>KMP but not Boyer-Moore for example and i am not sure what the
>>repurcassions of above approach are etc etc.
> 
> 
> This is a weakness of the current implementation, it could be
> addresses via the other method that I proposed. The current patch
> doesn't allow for random access over fragment borders which means
> that Boyer-Moore would require a temporary buffer with a size of
> the pattern length in order to do random access over multiple
> fragments. However, I haven't seen any infrastructure yet that can
> handle non-linear data with bm wihout a complete prefetch in the
> beginning though. You could still implement a bm by either using a
> naive search at the borders or simply define the limitation that you
> can only look at the first fragment so you'd have to linearize.

For small pattern and long packets, such pattern searching on the 
fragment borders doesn't really hurt the performance. Anyway the matter 
of having several algorithms will let users choose that one that suits 
better their needs.

boyer-moore (BM) and other variants are definitely a must to have. I'm 
still reading some papers about string matching and practical 
applications (p2p traffic recognition based on string matching, ids, etc 
etc) and the most interesting practical results come always from the use 
of BM friends.

>>I think the best approach would be to first linearize then search. 
> 
> 
> This is what I'm trying to avoid. ;->

sure, agree with Thomas.

Netfilter used to follow this approach in early 2.6 kernels and Patrick 
McHardy demostrated with some oprofile stuff that skb_copy_bits 
decreased performance.

I'm not familiar with those problems jamal has mentioned though, could 
they really affect the string matching infrastructure in some way? I 
truly prefer avoiding linearizing skb's.

>>The only other comment i have is on the patch you called naive regexp;
>>I think you should probably call it something else instead of regexp
>>since you invented it.
> 
> 
> I was never good at names, any suggestions?

nor me, i'd propose flamenco-dancing-regexp ;->.

--
Pablo
