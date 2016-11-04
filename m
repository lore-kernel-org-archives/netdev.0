From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: Coding Style: Reverse XMAS tree declarations ?
Date: Fri, 4 Nov 2016 21:06:58 +0100
Message-ID: <31ace8dd-1e42-2762-6367-028068d4d816@gmx.de>
References: <20161103.155816.642712588084106823.davem@davemloft.net>
 <1478242438.1924.31.camel@perches.com> <581C6A7D.8030704@marvell.com>
 <20161104.110759.1093635654135143910.davem@davemloft.net>
 <1478281455.1924.41.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: madalin.bucur@nxp.com, akpm@linux-foundation.org, corbet@lwn.net,
        netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org, oss@buserror.net,
        ppc@mindchasers.com, pebolle@tiscali.nl,
        joakim.tjernlund@transmode.se, Randy Dunlap <rdunlap@infradead.org>
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
        lsanfil@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478281455.1924.41.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04.11.2016 18:44, Joe Perches wrote:
> On Fri, 2016-11-04 at 11:07 -0400, David Miller wrote:
>> From: Lino Sanfilippo <lsanfil@marvell.com>
>> > On 04.11.2016 07:53, Joe Perches wrote:
>> >> CHECK:REVERSE_XMAS_TREE: Prefer ordering declarations longest to
>> >> shortest
>> >> #446: FILE: drivers/net/ethernet/ethoc.c:446:
>> >> +                    int size = bd.stat >> 16;
>> >> +                    struct sk_buff *skb;
>> > should not this case be valid? Optically the longer line is already
>> > before the shorter.
>> > I think that the whole point in using this reverse xmas tree ordering
>> > is to have
>> > the code optically tidied up and not to enforce ordering between
>> > variable name lengths.
>> 
>> That's correct.
> 
> And also another reason the whole reverse xmas tree
> automatic declaration layout concept is IMO dubious.
> 
> Basically, you're looking not at the initial ordering
> of automatics as important, but helping find a specific
> automatic when reversing from reading code is not always
> correct.
> 
> Something like:
> 
> static void function{args,...)
> {
> 	[longish list of reverse xmas tree identifiers...]
> 	struct foo *bar = longish_function(args, ...);
> 	struct foobarbaz *qux;
> 	[more identifers]
> 
> 	[multiple screenfuls of code later...)
> 
> 	new_function(..., bar, ...);
> 
> 	[more code...]
> }
> 
> and the reverse xmas tree helpfulness of looking up the
> type of bar is neither obvious nor easy.
> 

In this case it is IMHO rather the declaration + initialization that makes
"bar" hard to find at one glance, not the use of RXT. You could do something like

 	[longish list of reverse xmas tree identifiers...]
 	struct foobarbaz *qux;
 	struct foo *bar;

 	bar = longish_function(args, ...);

to increase readability. 

Personally I find it more readable to always use a separate line for initializations
by means of functions (regardless of whether the RXT scheme is used or not). 
 
> My preference would be for a bar that serves coffee and alcohol.
> 

At least a bar like this should not be too hard to find :)

Regards,
Lino
