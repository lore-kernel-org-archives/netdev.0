From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: RE: Route cache performance under stress
Date: Mon, 9 Jun 2003 21:15:18 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609204257.L35799@shell.cyberus.ca>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092006420.12038@ns.istop.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: CIT/Paul <xerox@foonet.net>, 'Simon Kirby' <sim@netnation.com>,
	"'David S. Miller'" <davem@redhat.com>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: ralph+d@istop.com
In-Reply-To: <Pine.LNX.4.51.0306092006420.12038@ns.istop.com>
List-Id: netdev.vger.kernel.org



On Mon, 9 Jun 2003, Ralph Doncaster wrote:

> From personal experience, after trying numerous things for over a year one
> can get very frustrated.  Although your contribution has been useful, you
> are also guilty of wildly waving your hands around too.  Many moons ago
> when I lamented that my 2.2.19 kernel, 750Mhz duron, 3c59x core router
> performance sucked you told me NAPI would solve the performance problems.
> It didn't.  And Rob's latest numbers seem to show that even with the
> latest and greatest patches 148kpps is still a dream.  It's good to see
> that people are finally doing tests to simulate real-world routing
> (instead of just pretending the problem doesn't exist because they were
> able to get 148kpps in some contrived test).
>

I am not sure that foos tests are not contrived ;->
The man just hammers away at his routers with DOS tools;->
I feel like a shrink calming him down to stop doing that. hehe.

I am actually  not against using the DOS tools because they test the worst
case.
However, to solve a problem you need first to isolate it and
methodically squash the coakroches. For example, In 2.2.x you
wouldnt even see the problems that we have today because we had bigger
problems namely interupt issues. NAPI resolves that. When i told you
that i was basing it on facts.
We are now exposed to dst cache problems. Daves patches isolate and
resolve whats causing all this noise. First it was the cache distribution
which is now resolved. Next it is garbage collection which it seems to
me is being resolved. When someone working so hard like Dave is putting
out these fires we need to help him. If he tells foo to run a specific
test then thats what he should run ... I dont think we should just add
CISCOs CEF just because someone thinks it works better. We need to
systematically isolate and fix.
For example just turning on netfilter is poluting the results.

Problem is people disappear real quick when asked to run tests that
could validate certain concepts. I wish everyone would emulate S Kirby
he actually gives good info.

> Here's my CPU graphs for the box; it's only doing routing and firewalling
> isn't even built into the kernel (2.4.20 with 3c59x NAPI patches)
> http://66.11.168.198/mrtg/tbgp/tbgp_usrsys.html
>
> eth1 and eth2 are both sending and receiving ~30mbps of traffic (at
> 8-10kpps in and out on each interface).
>

Is this still the duron 750Mhz? Are you running zebra? Did you
check out some of the ideas i talked about earlier?

> The other variable that I haven't seen people discuss but have anecdotal
> evidence will measurably impact performance is the motherboard used
> (chipset and chipset configuration/timing).
>

Robert has a good collection for what is good hardware. I am so outdated
i dont keep track anymore. My fastest machine is still an ASuse dual
450Mhz.

> Lastly from the software side Linux doesn't seem to have anything like
> BSD's parameter to control user/system CPU sharing.  Once my CPU load
> reaches 70-80%, I'd rather have some dropped packets than let the CPU hit
> 100% and end up with my BGP sessions drop.
>

Well, heres a good example: With NAPI, have your sessions been dropped?
Have you tried a different NIC? Not sure how well the 3com is maintained
for example.
Try a tulip or tg3 or e1000 or the dlink gige.

cheers,
jamal
