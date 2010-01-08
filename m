From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Fri, 8 Jan 2010 22:29:23 +0100
Message-ID: <20100108212923.GA3078@del.dom.local>
References: <4B459368.2000503@majjas.com>
 <4B45F841.8030407@majjas.com>
 <20100107180114.GB3088@del.dom.local>
 <4B4625BD.3070202@majjas.com>
 <20100107183545.GA3208@del.dom.local>
 <4B462B3C.90506@majjas.com>
 <20100107185040.GB3208@del.dom.local>
 <4B466A26.5070506@majjas.com>
 <20100108074539.GA6205@ff.dom.local>
 <4B475FF9.7000702@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754183Ab0AHV3c@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B475FF9.7000702@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 08, 2010 at 11:40:25AM -0500, Michael Breuer wrote:
> On 1/8/2010 2:45 AM, Jarek Poplawski wrote:
> >On Thu, Jan 07, 2010 at 06:11:34PM -0500, Michael Breuer wrote:
> >??? Hmm... Alternative 1 or 2 doesn't even compile into when no MMAP,
> >so it definitely needs re-retesting ;-)
> I see your point. I'm pretty sure that run failed miserably. Perhaps
> something else is going on - some sort if intermittent thing that
> just got caught there... have one thought - see below.

It looks like very timing dependent and without MMAP it can work just
below limit, which could trigger those dmar or msi bugs. Anyway, it
seems to show there is no another serious bug in the MMAP part (i.e.
except the one fixed be alternative 1 or 2 patches).

> >>* MMAP + NO DMAR + disable_msi=1... also works w/o errors... leaving
> >>this one running for a while - also completed a backup successfully.
> >>Fastest of the lot... about 3x faster than any other version, working or
> >>not.
> >Very interesting. It would be nice to give it a really long try, and
> >if still true, try MMAP + NO DMAR only.
> Still up - no kernel errors reported. There was a large dropped
> packet rate  (RX) which seems to actually correlate with DNS format
> error messages (ipv6 only). I spent some time tracking those down.
> Interestingly, most pointed back to one netblock & one ISP (0qf.ru).
> I blocked that domain and the errors expectedly dropped - as did the
> RX dropped packet rate.  Since booting this version yesterday eth0
> shows 1752944 dropped packets. 1752939 of those happened before I
> blocked the domain about 8 hours ago. I have run load tests since as
> well.
> 
> I think this dns activity is sendmail attempting to validate spam -
> but not 100% sure yet as I can't correlate the .ru domain with
> anything sendmail has reported. I'm running a sniffer now hoping to
> catch the next one. I *think* but can't prove, that these are coming
> in via sendmail - i.e., bad email, not even spam really - just
> enough to get a system configured to do dns lookups as part of spam
> filtering to connect to the server in question. What comes back
> would seem to be corrupt ipv6 packets.
> 
> This gets us back somewhat to Berck Nash's reported problem. His
> report of sky2 failure was due to external attack. Could this be
> related? Is it possible that absent some set of the patches & config
> settings in this version that ipv6 bind activity involving corrupt
> (perhaps intentionally) packets is breaking something?

Berck Nash reported oopses during sky2 TX timeout recovery, which are
generally hardware/driver problems, and shouldn't be triggered by ip
level bugs, so it should be queried as a separate bug report.

> 
> Will try rerunning without disable_msi later (after I catch the dns
> thing in the sniffer).
> >>I'm leaving this one running for now. Not retesting jumbo for now. Be
> >>happy to help dig further.
> >>
> >>Tentative recommendations:
> >>
> >>1) The af alternative patch seems rather necessary. First alternative
> >>seems to be working, I'd suggest that be submitted and backported to
> >>2.6.32.

BTW, don't hurry with that yet, but in the next test, please try
alternative 2 again (i.e. with MMAP + no DMAR + disable_msi).

> >>2) Steven's pskb_may_pull patch also ought to be included and backported.

This patch is very helpful for debugging, but I doubt appropriate
for the mainline if it isn't triggered any more after 1) fix. But,
please keep it yourself for some time in all these tests (and of
course Berck Nash's patch).

> >OK, for now let's make sure this MMAP + NO DMAR + disable_msi is
> >really really working.
> Still running :)

Very nice :)
Jarek P.
