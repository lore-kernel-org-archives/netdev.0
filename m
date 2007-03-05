From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: Extensible hashing and RCU
Date: Sun, 4 Mar 2007 23:12:20 -0800
Message-ID: <f2b55d220703042312q6a83e00el862e63fe03e5b7c0@mail.gmail.com>
References: <f2b55d220703021245m5cd5d9eet5e5a9d0d8ffcea41@mail.gmail.com>
	 <20070303104620.GD22557@2ka.mipt.ru>
	 <f2b55d220703040202y7d6e5c72q8b5c8fd3d11fd06a@mail.gmail.com>
	 <20070304.123658.104032879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, dada1@cosmosbay.com, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.236]:11141 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708AbXCEHMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 02:12:24 -0500
Received: by wr-out-0506.google.com with SMTP id 37so1267643wra
        for <netdev@vger.kernel.org>; Sun, 04 Mar 2007 23:12:24 -0800 (PST)
In-Reply-To: <20070304.123658.104032879.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/4/07, David Miller <davem@davemloft.net> wrote:
> From: "Michael K. Edwards" <medwards.linux@gmail.com>
> > Before I implement, I design.  Before I design, I analyze.  Before I
> > analyze, I prototype.  Before I prototype, I gather requirements.
>
> How the heck do you ever get to writing ANYTHING if you work that way?

Oh, c'mon, the whole design process takes maybe 3 weeks for something
I'm going to spend 3 months implementing.  And half the time the
client mistakes the prototype for the implementation and tries to run
with it -- with the foreseeable consequences.  Smaller projects are a
lot less formal but the principle still holds: every time I've
implemented without actually doing the homework leading up to a
design, I've had cause to regret it.  That goes double for problems
that already have off-the-shelf solutions and only need improvement in
ease of use and robustness in hostile environments.

> I certainly would never have written one single line of Linux kernel
> code if I had to go through that kind of sequence to actually get to
> writing code.

Lots of _code_ gets written as a side effect of each stage of that
sequence.  But none of that code should be mistaken for the
_implementation_.  Not when the implementation is going to ship inside
hundreds of thousands of widgets that people are going to stick in
their ears, or is going to monitor the integrity of an
intercontinental telecoms network.  Most shipping code, including most
code that I have written and large swathes of the Linux kernel, has
never really gone beyond the prototype stage.  There's no shame in
that; the shame would be in refusing to admit it.

> And that's definitely not the "Linux way".  You code up ideas as soon
> as you come up with one that has a chance of working, and you see what
> happens.  Sure, you'll throw a lot away, but at least you will "know"
> instead of "think".

I call that process "prototyping".  I used to do a lot of it; but I
have since found that thinking first is actually more efficient.
There is very little point in prototyping the square wheel again and
again and again.  And especially given that Linux already has plenty
of nice, round wheels, there aren't that many places left where you
can impress the world by replacing a square wheel with a hexagonal
one.  Replacing wheels with maglev tracks requires a real design
phase.

> You have to try things, "DO" stuff, not just sit around and theorize
> and design things and shoot down ideas on every negative minute detail
> you can come up with before you type any code in.  That mode of
> development doesn't inspire people and get a lot of code written.

I'll cop to the "negative" part of this, at least to some degree, but
not the rest.  "Naive hashes DDoS easily" is not a minute detail.
"Hash tables don't provide the operations characteristic of priority
queues" is not a minute detail.  "The benchmarks offered do not
accurately model system impact" is not a minute detail.  If I were not
sufficiently familiar with some of Evgeniy's other contributions to
the kernel to think him capable of responding to these critiques with
a better design, I would not have bothered.

> I definitely do not think others should use this
> design/prototype/analyze/blah/balh way of developing as an example,
> instead I think folks should use people like Ingo Molnar as an example
> of a good Linux developer.  People like Ingo rewrite the scheduler one
> night because of a tiny cool idea, and even if only 1 out of 10 hacks
> like that turn out to be useful, his work is invaluable and since he's
> actually trying to do things and writing lots of code this inspires
> other people.

Ingo Molnar is certainly a good, nay an excellent, Linux developer.
His prototypes are brilliant even when they're under-designed by my
way of thinking.  By all means, readers should go thou and do
likewise.  And when someone presses an alternative design, "show me
the code" is a fair response.

At present, I am not offering code, nor design, nor even a prototype.
But I am starting to figure out which bits of the Linux kernel really
are implementations based on a solid design.  Any prototyping I wind
up doing is going to be bolted firmly onto those implementations, not
floating in the surrounding sea of prototype code; and any analysis I
offer based on that prototype will reflect, to the best of my ability,
an understanding of its weaknesses as well as its strengths.  If that
analysis passes community scrutiny, and if I remain interested in the
project, perhaps I will go through with design and implementation as
well.

This, incidentally, seems very similar to the process that Robert
Olsson and Stefan Nilsson have gone through with their trie/hash
project.  Although I haven't tried it out yet and don't have any basis
for an independent opinion, the data and analysis provided in their
paper are quite convincing.  Any prototyping I might do would probably
build on their work, perhaps adding a more explicit DDoS-survival
strategy based on a priority (heap) index and rotation tactics that
preserve it.  Based on my current understanding that would shade it in
the direction of a splay tree; but I am no expert on data structures
and it may take me some time to think it through completely.  In the
meantime, I am inclined to hold them up as an inspiring example.  :-)

Cheers,
- Michael
