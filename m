From: David Brownell <david-b@pacbell.net>
Subject: Re: 2.5.50 BUG_TRAP on !dev->deadbeaf, and oopses
Date: Mon, 09 Dec 2002 11:51:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DF4F436.6020807@pacbell.net>
References: <3DE9290A.7070502@pacbell.net> <3DEA0452.B1F15BFD@isg.de>
 <3DEBA9F5.6000606@pacbell.net> <3DF3CAC8.5070309@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Is there someone who has a clear explanation of exactly how "deadbeaf"
> was once expected to work -- and now (since sometime before about
> 2.5.40) evidently doesn't?
> 
> It seems to be driven by side effects, and whatever comments are in
> the code aren't any help.  The only case "deadbeaf" could be set is
> still documented as an error path ... 

All that still holds true.  There's something fishy going on, or
just old cruft that's lingered.  I suppose I should just patch it
and see if contradictory information appears then.

>> Plus: this kind of bugcatch should use magic numbers, or maybe zero.
>> Assuming "any nonzero value is valid", like this assertion does, is
>> clearly going to fail for any of the class of bugs highlighted by
>> slab poisoning.  (0xa5a5a5a5 gets accepted as valid...)

Actually I found a place where the wrong pointer was being used.
Heh -- lucky me, to make my point that way ... a stray pointer
happened to point to a zero, and so triggered that warning.  As a
bugcatch it's pretty poor:  it wouldn't normally trigger on that
kind of bug, either.

- Dave
