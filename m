From: Avery Pennarun <apenwarr@google.com>
Subject: Re: [Cerowrt-devel] Fwd: Throughput regression with `tcp: refine TSO autosizing`
Date: Sun, 1 Feb 2015 23:21:56 -0500
Message-ID: <CAPp0ZBa43kVBWN5iGgmW=-YQAkdm2DrmMN0URvVu=yXA-_TZCQ@mail.gmail.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
 <1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
 <54CB5D08.2070906@broadcom.com> <1422623975.21689.77.camel@edumazet-glaptop2.roam.corp.google.com>
 <54CB8B69.1070807@broadcom.com> <CAA93jw5fqhz0Hiw74L2GXgtZ9JsMg+NtYydKxKzGDrvQcZn4hA@mail.gmail.com>
 <CAA93jw7b0E9jjQYXrEPzjLLC9j8xNC0TFYXpWVtgFameJaNBdw@mail.gmail.com>
 <1422741065.199624134@apps.rackspace.com> <CAPp0ZBb2nkA6Y0s=W0kw=zvyn0wi0NMBRsBCw_xcD61ScOmgQg@mail.gmail.com>
 <CAA_e5Z46Bu+zZZFzf_ejzA35Gw3g1_OG85yv6yd7MpbwZcE-nw@mail.gmail.com>
 <CAA93jw7=oTex0Mp-0ThvuDRUnfR0N8tzdOQ8DD7QYWphp1b=4w@mail.gmail.com>
 <CAJq5cE3ETbpEtecFHmhgHQveNRUhVfrzjTOygHm-TRCTwHNyKA@mail.gmail.com> <1422801814.796219699@apps.rackspace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jonathan Morton <chromatix99@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Matt Mathis <mattmathis@google.com>,
	Tim Shepard <shep@alum.mit.edu>, dstanley@arubanetworks.com,
	Kathy Giori <kgiori@qca.qualcomm.com>,
	Stig Thormodsrud <stig@ubnt.com>,
	Derrick Pallas <pallas@meraki.com>,
	"cerowrt-devel@lists.bufferbloat.net"
	<cerowrt-devel@lists.bufferbloat.net>,
	Mahesh Paolini-Subramanya <mahesh@dieswaytoofast.com>,
	Jim Gettys <jg@freedesktop.org>,
	Andrew McGregor <andrewmcgr@gmail.com>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org
To: David Reed <dpreed@reed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:46697 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754893AbbBBEWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2015 23:22:17 -0500
Received: by mail-qg0-f51.google.com with SMTP id z107so45827385qgd.10
        for <netdev@vger.kernel.org>; Sun, 01 Feb 2015 20:22:16 -0800 (PST)
In-Reply-To: <1422801814.796219699@apps.rackspace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 1, 2015 at 9:43 AM,  <dpreed@reed.com> wrote:
> Just to clarify, managing queueing in a single access point WiFi network is
> only a small part of the problem of fixing the rapidly degrading performance
> of WiFi based systems.

Can you explain what you mean by "rapidly degrading?"  The performance
in odd situations is certainly not inspirational, but I haven't
noticed it getting worse over time.

> Similarly, mesh routing is only a small part of the
> problem with the scalability of cooperative meshes based on the WiFi MAC.

That's certainly true.  Not to say the mesh routing algorithms are
much good either.

>  Also, as we noted
> earlier, "handoff" from one next hop to another is a huge problem with
> performance in practical deployments (a factor of 10x at least, just in
> that).

While there is definitely some work to be done in handoff, it seems
like there are some find implementations of this already in existence.
Several brands of "enterprise access point" setups seem to do well at
this.  It would be nice if they interoperated, I guess.

The fact that there's no open source version of this kind of handoff
feature bugs me, but we are working on it here and the work is all
planned to be open source, for example: (very early version)
https://gfiber.googlesource.com/vendor/google/platform/+/master/waveguide/

> Propagation information is not used at all when 802.11 systems share a
> channel, even in single AP deployments, yet all stations can measure
> propagation quite accurately in their hardware.

802.11k seems to provide for sharing this information.  But I'm not
clear what I should use it for. :)

> Finally, Listen-before-talk is highly wasteful for two reasons: 1) any
> random radio noise from other sources unnecessarily degrades communications [...]
> 2) the transmitter cannot tell when the intended receiver will be perfectly
> able to decode the signal without interference with the station it hears
> (this second point is actually proven in theory in a paper by Jon Peha that
> argued against trivial "etiquettes" as a mechanism for sharing among
> uncooperative and non-interoperable stations).

I've thought quite a bit about your point #2 above, but I don't know
which direction to pursue.  The idea is that sometimes "just shout
over the background noise" is a globally optimal solution, right?  The
question seems to be to figure out when that is true and when it
isn't.

> I agree that, to the extent that managing queues in a single box or a single
> operating system doesn't require cooperation, it's much easier to get such
> things into the market.  That's why CeroWRT has been as effective as it has
> been.  But has Microsoft done anything at all about it?   Do the better ECN
> signals that can arise from good queue management get used by the TCP
> endpoints, or for that matter UDP-based protocol endpoints?

If we don't know the answer to the questions, then that is itself the
problem.  It's a lot easier to say, hey, ChromeOS and MacOS have good
network performance but Microsoft has bad network performance, if it's
true and we have good reproducible tests to demonstrate that.

> The reason no one is making progress on any of these particular issues is
> that there is no coordination at the "systems level" around creating rising
> tides that lift all boats in the WiFi-ish space.  It's all about ripping the
> competition by creating stuff that can sell better than the other guys'
> stuff, and avoiding cooperation at all costs.
> [...]
> But the big wins in making WiFi better are going begging.  As WiFi becomes
> more closed, as it will as the major Internet Access Providers and Gadget
> builders (Google, Apple) start excluding innovators in wireless from the
> market by closed, proprietary solutions, the problem WILL get worse.  You
> won't be able to fix those problems at all.  If you have a solution you will
> have to convince the oligopoly to even bother trying it.

As someone who works at Google Fiber (which is both a gadget maker and
an ISP) and who pushes all day long for our wifi stuff to be open
source, I'm slightly offended to be lumped in with other vendors in
your story :)  I think the ChromeOS team (which insists on only open
source wifi drivers in all chromebooks) would feel similarly.  We are
lucky to have defined our competitive advantage as something other
than short-lived slight improvements in wifi that will soon be
wastefully duplicated by everyone else.

That said, I see what you mean about the general state of the
industry.  The way to fix it is the way Linux always fixes it: make
the open source version so much better that building a proprietary
one, just to gather a small incremental advantage, is a huge waste of
time and effort.  Work on minstrel and fq_codel go really far here.

> I personally think that things like promoting semi-closed, essentially
> proprietary ESSID-based bridged distribution systems as "good ideas" are
> counterproductive to this goal.  But that's perhaps too radical for this
> crowd.

Not sure what you mean here.  ESSID-based distribution systems seem
pretty well defined to me.  The only proprietary part is the
decision-making process for assisted roaming (ie. the "inter-AP
protocol") which is only an optional performance optimization.  There
really should be an open source version of this, and I'm in fact
feebly attempting to build one, but I don't feel like the world is
falling apart through not having it.  You can build a bridged
multi-BSS ESSID today with plain out-of-the-box hostapd.

Have fun,

Avery
