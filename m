From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: [fw@deneb.enyo.de: Route cache performance under stress]
Date: Sun, 06 Apr 2003 00:55:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <873ckwftal.fsf@deneb.enyo.de>
References: <20030405165016.GA32361@outpost.ds9a.nl>
	<20030405134350.N68419@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20030405134350.N68419@shell.cyberus.ca> (jamal's message of
 "Sat, 5 Apr 2003 14:02:19 -0500 (EST)")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> writes:

>> Short summary: It is possible to freeze machines with 1 GB of RAM and
>> more with a stream of 400 packets per second with carefully chosen
>> source addresses.  Not good.
>>
>
> I dont think the author has done any testing actually at the rate they
> claim to have to - if they did they wouldnt be wording it as "carefully
> chosen source addresses".

Why don't you ask the author the wording is unclear?

>> The route cache is a DoS bottleneck in general (that's why I started
>> looking at it).
>
> Yes it is - but not using the reasons described above.

Have you actually read the paper?  Do you understand its implications
for the dst cache?

> I think two issues are being mixed here: One the dst cache and two
> the SYN attacks. The TCP SYNs are more vulnerable than dst cache
> and rate control of SYNs may remedy the issue.

Currently, the dst cache (which is a misnomer, as it includes the
source address and TOS field) is not only a bottleneck, you can
actually abuse it for DoS attacks.

Some people told me that the general performance issues are rather
well-known.  Why aren't they being addressed?

> And why could this not have been done in /proc?

Ugh, thanks.  I didn't notice that this part is actually tunable.

> Is this supposed to cure something?

Garbage collection is much more aggressive and the chains attached to
the bucket are kept much shorter, so less CPU time is spent processing
them.

> In any case i think it is extremely dangerous to read some academic
> paper

Have you read it?  I doubt it.

> and start waving hands around about how it applies here.

I discovered the paper *after* writing the DoS tool.

I wrote the DoS tool *after* investigating why a server froze during a
2 Mbit/s SYN flood which was being dropped by an iptables rule (in the
INPUT chain, admittedly).

Please stop your ad hominem attacks.

> Do some tests and come up with data of where things need to be
> improved.

I have already done this, and I think I have provided the necessary
information to reproduce this.  For obvious reasons, I don't want to
release the DoS tool before a real fix is available.

> Just pointing a finger at hashing is insufficient

I'm not pointing a finger at hashing, but at hash collisions.

> (infact i dont think hashing is the primary issue based on some
> experiments foo and i did)

Where can I read about your testing methods?  There must be some flaw
because reality looks quite different.

Maybe you tested with non-random source addresses, or some "Internet
mix" traffic.  Such tests look fine on glossy paper, but you shouldn't
assume that they tell anything about the robustness of networking
devices in the presence of malicious traffic.
