From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: RE: Route cache performance under stress
Date: Tue, 10 Jun 2003 09:36:31 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610091736.V37313@shell.cyberus.ca>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092006420.12038@ns.istop.com> <20030609204257.L35799@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092200150.28167@ns.istop.com> <20030610061010.Y36963@shell.cyberus.ca>
 <Pine.LNX.4.51.0306100828220.26498@ns.istop.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: CIT/Paul <xerox@foonet.net>, "'Simon Kirby'" <sim@netnation.com>,
   "'David S. Miller'" <davem@redhat.com>,
   "fw@deneb.enyo.de" <fw@deneb.enyo.de>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com
In-Reply-To: <Pine.LNX.4.51.0306100828220.26498@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 10 Jun 2003, Ralph Doncaster wrote:

> On Tue, 10 Jun 2003, Jamal Hadi wrote:
>
> > I thought you were saying those were _not_ real world traffic patterns.
>
> I'm saying the tests that you and Rob did in the past did not reflect
> real-world use of Linux as a core router (i.e. small routing table and not
> many different traffic flows).  The tests he posted yesterday are a big
> step forward.
>

I think at a minimal define what "real world" means.
Is it 100 flows/sec at 20Kpps? what is it?

> > Typically, real world is less intense than the lab. Ex: noone sends
> > 100Mbps at 64 byte packet size. Typical packet is around 500 bytes
> > average. If linux can handle that forwarding capacity, it should easily
> > be doing close to Gige real world capacity.
>
> No, it needs to work in the worst case.  If some script kiddie can peg my
> CPU with a synflood then there's still a problem.
>

Lets work on defining "real world". Factor in the script kiddie.

> Sure I realize that.  The problem I've seen occur is that Linux developers
> with big egos say "linux can route as well as a cisco 3640", or "linux
> routing is beats BSD any day".  Then guys like me decide to give it a try,
> not realizing we're walking into a tarpit.  If I had been told in the
> first place that running linux as a high-throughput router in a service
> provider environment was an unknown, things would have been different.
>

Heres where the problem is:
If you interact at this low level then you oughta produce low level
input. Provide people with data to help. Otherwise its a high maintanance
task.

> > I have spent many hours investigating peoples problems sshing to their
> > machines only to find out they didnt follow instructions. After the
> > 10th person doing the same thing, what do you expect my reaction to be?
>
> Take 15 minutes and write a web page with the magic settings required to
> make things work.
>

I have many times. I still do. It is also a thankless task.

> > I think you may be suffering from the "too low" traffic NAPI syndrome.
> > Under low traffic (1-2 Mbps) on lower end machines NAPI will consume
> > more CPU because of an extra PCI operation per packet that is performed.
>
> No, as I said I'm moving ~30mbps and ~10kpps in and out of 2 3c905cx
> cards.
>

Change your NICs. I dont know what else to suggest.

> > As for the zebra thing, if you post my message to the Zebra list i am sure
> > someone will be excited enough to do it. I need a few hours to do it
> > but like you i dont have much time.
>
> The last time I looked at the zebra list things seemed pretty dead.  Most
> of the new work is now happening on the commercial zebra development.
>

Maybe its time to fork Zebra into something that has the same momentum it
had in the earlier days.

> > yes, move to the giges then lets talk again. I think your main problem is
> > that 3com NAPI is not well supported. Lennert disappeared right after he
> > released the patch and noone else has the interest of maintaining it.
>
> Yes, and it would be nice if you mentioned in your NAPI docs that people
> should use a tulip, tg3, or e1000 if they want it to work well.  In making
> your sales pitches for NAPI you made it sound like any high-performance
> card should do fine (i.e. anything but a Realtek).
>

Theres a URL which points people to where the various NICS supported are.

> On his first graph, for 50k new incoming dst/sec throughput looks to be
> ~175kpps.  And he's running a 1.8Ghz Xenon vs my 750Mhz Duron.
>

i think what would be interesting is to show CPU utilization as well.

> > This is why you dont get very positivre reaction. You use religious
> > scripture and you expect that people will help prove you are wrong.
>
> You don't seem to get it.  There's at least a dozen things more important
> to me than seeing Linux routing performance compete with Cisco and BSD.

Again, if you wanna complain about it at the level you are i think its
only fair you help. I actually dont care about CISCO or BSD. We dont win
because someone else looses. We simply want to be the best.
If you tell me BSD works better, i told you i will walk all the way
downtown in the hope i'll find somethuing we can improve on.

> I'm annoyed that people like you have told me linux is up to the task, and
> then when it's not I'm left SOL.  I thought I was talking to competent
> techies, but now I see most of the techies were also Linux evangelists.
>
> Now that people like Rob and Dave are taking a hard look at it I think
> it's worth my while to ante up for a couple more rounds.  I still fell
> like a sucker that should have walked away from the table a long time ago
> though.
>

I think your setup maybe the question. Like i said theres probably a
hunderd variables involved. It is up to you to isolate things.
Yes, theres a support line in open source, but it is rewarded more
when people show some effort.

> Jim Mercer and Marc Ackley at 151.net/tht.net told me they tried
> Linux/Zebra and gave up (and went with 7206vxr routers).  And they're very
> pro-unix (still do all their netflow collection and billing on Unix).
> They're not likely to go back and give Linux another try.  If the linux
> evangelists had just said Linux would be ready for core routing in a year
> (or whatever) instead, I think network operators would look at it more
> seriously rather than they joke that they see it as now.
>

Theres a lot of BSD bigots in a lot of ISPS and IETF. It's human nature
to be comfortable with what they know best. Most of the people i have
met that put Linux down or consider it a joke come from the old
BSD camp. Its their loss and i dismiss anything they have to say.
Lets work on facts. What is it that we can do to improve Linux?
Provide data. If you want to compare against BSD, what is it that
_ you have facts on_ and not heard from other people that BSD does better?

cheers,
jamal
