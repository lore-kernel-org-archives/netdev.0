From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: RE: Route cache performance under stress
Date: Tue, 10 Jun 2003 06:53:04 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030610061010.Y36963@shell.cyberus.ca>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092006420.12038@ns.istop.com> <20030609204257.L35799@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092200150.28167@ns.istop.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: CIT/Paul <xerox@foonet.net>, 'Simon Kirby' <sim@netnation.com>,
	"'David S. Miller'" <davem@redhat.com>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: ralph+d@istop.com
In-Reply-To: <Pine.LNX.4.51.0306092200150.28167@ns.istop.com>
List-Id: netdev.vger.kernel.org



On Mon, 9 Jun 2003, Ralph Doncaster wrote:

> On Mon, 9 Jun 2003, Jamal Hadi wrote:
>
> The test results Rob posted today show that the testing can be done in a
> lab environment.

I thought you were saying those were _not_ real world traffic patterns.
Robert is just doing a worst case scenario testing. What would be useful
is we actually test on real environments or maybe even collect real
world traffic patterns and run them in the lab.
Typically, real world is less intense than the lab. Ex: noone sends
100Mbps at 64 byte packet size. Typical packet is around 500 bytes
average. If linux can handle that forwarding capacity, it should easily
be doing close to Gige real world capacity.
Have you seen how the big boys advertise? when tuning specs they talk
about bits/sec. Juniper just announced a blade at supercom that can do
firewalling at 500Mbps.

> Most of the people I know that would actually see 50kpps
> in the real world don't have the time to apply various patches and run a

Now thats one big dilema, isnt it? Do you think i have time? Let me
assure you that I dont get paid by anybody to do any of this stuff.
Infact i havent been paid to do any of this stuff since 1994. Thats a lot
of man hours in corporate speak.
The point i am making is as a community we gotta put the hours together;
the coder, the user etc. As someone who is not maintaining anything
(lucky bastard that i am, my name is not even in the credits file - by
choice) so i have the luxury to  disappear once in a while. Imagine Davems
reaction to a message like the above.

> bunch of tests; pretending the problem doesn't exist when someone doesn't
> run tests to prove is a poor excuse.
>

I think you _may_ be right theres a problem. However, as a defensive
mechanism it is easier to tell someone to go away and come back with
solid data. For example, you CPU graphs are very strange: Theres a few
hundred variables that may be involved.
I have spent many hours investigating peoples problems sshing to their
machines only to find out they didnt follow instructions. After the
10th person doing the same thing, what do you expect my reaction to be?
Please see the view from this side as well because it is almost
a thankless task.

> Yup, still a duron 750 on an Asus mobo (Via chipset).  Running Zebra
> 0.93b.  If the ideas you're referring to are changing the zebra source to
> arp the next-nops, then no, I haven't tried it (and am not likely to any
> time soon).
>

I think you may be suffering from the "too low" traffic NAPI syndrome.
Under low traffic (1-2 Mbps) on lower end machines NAPI will consume
more CPU because of an extra PCI operation per packet that is performed.
As for the zebra thing, if you post my message to the Zebra list i am sure
someone will be excited enough to do it. I need a few hours to do it
but like you i dont have much time.

> > Robert has a good collection for what is good hardware. I am so outdated
> > i dont keep track anymore. My fastest machine is still an ASuse dual
> > 450Mhz.
>
> There's still more dead-end suggestions than good ones (i.e. the
> O'Reilley high performance routing book).
>

URL?

> > Well, heres a good example: With NAPI, have your sessions been dropped?
> Yup, twice in the last 2 weeks.
>

I have seen NAPI slow down throughput because of an intensive user space
app.

> > Have you tried a different NIC? Not sure how well the 3com is maintained
> > for example.
> > Try a tulip or tg3 or e1000 or the dlink gige.
>
> Initially I was looking for tulip cards but almost nobody is producing
> them any more.  Almost a year ago I came across the following list, which

Thats not true. You could buy them off znyx. Yes, intel has EOLed the
chips so i dont think Znyx will be doing this for much longer.
Get yourself the giges instead.

> is why I went with the 3com (at the time it indicated rx/tx irqmit for the
> 3com, until I emailed the author that I found out it was tx only)
> http://www.fefe.de/linuxeth/
>
> I had joined the vortex list last fall looking for some tips and that
> didn't help much (other than telling me that the 3com wasn't the best
> choice).  I've since bought a couple tg3 and a bunch of e1000 cards that
> I'm planning to put into production.
>

yes, move to the giges then lets talk again. I think your main problem is
that 3com NAPI is not well supported. Lennert disappeared right after he
released the patch and noone else has the interest of maintaining it.

> Rob's test results seem to show that even if I replace my 3c905cx cards
> with e1000's I'll still get killed with a 50kpps synflood with my current
> CPU.  Upgrading to dual 2Ghz CPUs is not a preferred solution since I
> can't do that in a 1U rack-mount box.  Yeah, I could probably do it with
> water cooling, but that's not an option in a telco hotel like 151 Front
> St. (Toronto).
>

where are you getting the 50Kpps data from? I see him talkking of
input rate of no less than 200Kpps.

> A couple weeks ago I got one of my techs to test freeBSD/polling with full
> routing tables on a 1Ghz celeron and 2 e1000 cards.  His testing seems to
> suggest it will handle a 50kpps synflood DOS.  It would be nice if Linux
> could do the same.
>
> Despite the BSD bashing (to be expected on a Linux list, I guess), I will
> be using BSD as well as Linux for core routing.  The plan is 1 linux
> router and 1 bsd router each running zebra, connected to separate upstream
> transit providers, running ibgp between them, and both advertising a
> default route into OSPF.  Then if I get hit with a DOS that kills Linux,
> the BSD box will have a much better chance of staying up than if I just
> used a second Linux box for redundancy.  If the BSD boxes turn out to have
> twice the performance of the linux boxes, it may be better for me to dump
> linux for routing altogether. :-(
>

This is why you dont get very positivre reaction. You use religious
scripture and you expect that people will help prove you are wrong.
Let the person who showed that BSD can do better publish the data.
If they are in town, let me know because i am willing to walk to
meet the challenge.
Maybe we'll learn something.

cheers,
jamal
