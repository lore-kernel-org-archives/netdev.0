From: Andi Kleen <ak@muc.de>
Subject: Re: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Sat, 19 Mar 2005 21:15:02 +0100
Message-ID: <m17jk35r5l.fsf@muc.de>
References: <200503151507.j2FF7sDD011131@guinness.s2io.com>
	<200503151555.j2FFtqDD019050@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@oss.sgi.com>, <leonid@neterion.com>, <jgarzik@pobox.com>,
        "'Andi Kleen'" <ak@muc.de>
To: "Leonid Grossman" <leonid.grossman@neterion.com>
In-Reply-To: <200503151555.j2FFtqDD019050@guinness.s2io.com> (Leonid
 Grossman's message of "Tue, 15 Mar 2005 07:55:51 -0800")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Leonid Grossman" <leonid.grossman@neterion.com> writes:

>> 
>> > Leonid Grossman writes:
>> It's not the best maintenance option (both for us and arguably, even for a
>> non-primary-author kernel hackers) but it's workable.
>
> The statement about non-primary-author kernel hacker interests needs some
> clarification, before people started to throw things at me. 
> This is the last argument before I shut up, I promise :-)


First you wont like it, but Linux kernel maintainers usually dont give
firm promises to merge anything.  They just say "with that i wont merge it"
and even that is flexible sometimes. It is not like a company who
gives commitments or signs contracts, it is really the final patch that counts.

The best way to get code merged is to write it like the maintainers
wants it, but of course that does not happen always.

However when the code is clean and the biggest issues are fixed
and only some relatively small ones are left I think you have a good
chance to see your code merged.


>
> Arguably, a hacker will be much more interested in changing the non-HAL part
> of a driver. This part of the code has to look and feel the same as any
> other Linux net driver. If it doesn't, then we've done a poor job and need
> to go back.

There are currently some issues, mostly the "LAL" in it (Linux Adaption
Layer that wraps everything) and all the ugly function parameters (IN and 
__STATIC_* and the wrapped list functions ). That is what just poked in my 
eyes at the first look.

I personally dont care that much about the later stuff which
is more cosmetic, but a lot of other people strongly object to 
code that does not look like other Linux code so I would recommend to 
fix it. 


What I also did not like was that you had high level logic in these
HAL parts - like handling packet queues etc. Normally IMHO high level
logic should be directly in the functions that are directly called
from the kernel. This way it is easy to follow the main logic
of the driver if someone is familiar with linux network drivers
in general

LALs are strongly frowned at upon and I personally also dont like them
at all. AFAIK there is one two drivers in the kernel tree that have 
it and it is considered an historic accident by everybody I know  ,=)


> In our experience, the vast majority of code fixes and new features in the
> HAL code comes from our team (hey, we planted all these bugs to begin with
> :-)), and to a much lesser extend from other OS developers, and only then
> from Linux community. 

The problem is usually that when there is some bug in your driver
and someone not in your company wants to debug it because the bug
is causing them problems (that is one of the great advantages of free 
software that they can do it themselves), then they want relatively
clean code. The same happens for the maintainer who is hunting some
issue and needs to change your driver slightly for some infrastructure
change. 

So even though most changes come likely from you there is a need
for other people to understand and change your code.

-Andi
