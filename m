From: jamal <hadi@cyberus.ca>
Subject: Re: [fw@deneb.enyo.de: Route cache performance under stress]
Date: Sat, 5 Apr 2003 18:48:42 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030405180607.P68419@shell.cyberus.ca>
References: <20030405165016.GA32361@outpost.ds9a.nl> <20030405134350.N68419@shell.cyberus.ca>
 <873ckwftal.fsf@deneb.enyo.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Florian Weimer <fw@deneb.enyo.de>
In-Reply-To: <873ckwftal.fsf@deneb.enyo.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sun, 6 Apr 2003, Florian Weimer wrote:

> jamal <hadi@cyberus.ca> writes:
>
> Why don't you ask the author the wording is unclear?

I meant whoever said that 400pps would cause a DOS. I didnt see the dst
cache test being described in the source, so i assume it is someone else
other than people who wrote the tool.

>
> > Yes it is - but not using the reasons described above.
>
> Have you actually read the paper?  Do you understand its implications
> for the dst cache?

I skimmed through it and got their message. Yes, i understand the
implications ;->

>
> > I think two issues are being mixed here: One the dst cache and two
> > the SYN attacks. The TCP SYNs are more vulnerable than dst cache
> > and rate control of SYNs may remedy the issue.
>
> Currently, the dst cache (which is a misnomer, as it includes the
> source address and TOS field) is not only a bottleneck, you can
> actually abuse it for DoS attacks.
>

yes you can.

> Some people told me that the general performance issues are rather
> well-known.  Why aren't they being addressed?
>

"Addressed" is a strong word but certainly they are being looked into
(for some time now). If you are enthusiastic and want to help, send
private mail to me.

> > Is this supposed to cure something?
>
> Garbage collection is much more aggressive and the chains attached to
> the bucket are kept much shorter, so less CPU time is spent processing
> them.

You may find that aggressive gc is one of your problems infact.

>
> > In any case i think it is extremely dangerous to read some academic
> > paper
>
> Have you read it?  I doubt it.
>

The skimming was good enough to get the mesage. I'll read it in more
details later after killing a small branch.

> > and start waving hands around about how it applies here.
>
> I discovered the paper *after* writing the DoS tool.
>
> I wrote the DoS tool *after* investigating why a server froze during a
> 2 Mbit/s SYN flood which was being dropped by an iptables rule (in the
> INPUT chain, admittedly).
>

I dont see the correlation of syn attacks and the dst cache in your
description. Can you collect some profiles?
400pps is peanuts for the dst cache even on a 386. OTOH, this may be an
issue for a SYN DOS.

> Please stop your ad hominem attacks.
>

Relax.

> > Do some tests and come up with data of where things need to be
> > improved.
>
> I have already done this, and I think I have provided the necessary
> information to reproduce this.  For obvious reasons, I don't want to
> release the DoS tool before a real fix is available.
>

There are a lot of tools already being used by kiddies out of
there but its a good idea not to arm them with one more.
Please collect some profiles and send them privately.

> > Just pointing a finger at hashing is insufficient
>
> I'm not pointing a finger at hashing, but at hash collisions.
>

I know thats what the paper says - but this is exactly what i have
problems with: In the little study we did, its not the collisions that
kill us rather the fact we are being forced into the slow path the
majority of times. Please collect the profiles and send me the tool as
well.

> > (infact i dont think hashing is the primary issue based on some
> > experiments foo and i did)
>
> Where can I read about your testing methods?  There must be some flaw
> because reality looks quite different.
>
> Maybe you tested with non-random source addresses, or some "Internet
> mix" traffic.  Such tests look fine on glossy paper, but you shouldn't
> assume that they tell anything about the robustness of networking
> devices in the presence of malicious traffic.

Actually try varying the dst address, it gets more interesting.
Our data was collected on a real ISP which hosts a lot of web servers
and was being constantly DOSed. I dont think you can get more real world
than that.
Talk to me privately about our tests - i am a little conservative about
wowing people with results without doing appropriate analysis. It is
possible you hit a different unrelated issue.

cheers,
jamal
