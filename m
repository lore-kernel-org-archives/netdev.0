From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Fri, 4 Dec 2015 14:44:00 -0800
Message-ID: <CAKgT0UepW=VehhXncrAM=tvqrVDD_KOdVJBpwEU+hYTAdMz_dg@mail.gmail.com>
References: <1449158374.11080.456996721.69F803D7@webmail.messagingengine.com>
	<CALx6S342OMLB6s7LcmnZP1rnYNUs345Dy1gjYX3JUKqqB_waPA@mail.gmail.com>
	<1449259145.6236.458303617.55CF2C4E@webmail.messagingengine.com>
	<20151204.150633.1744714566987717806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <tom@herbertland.com>,
	John Linville <linville@tuxdriver.com>, jesse@kernel.org,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37334 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754507AbbLDWoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 17:44:01 -0500
Received: by igcto18 with SMTP id to18so46583399igc.0
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 14:44:01 -0800 (PST)
In-Reply-To: <20151204.150633.1744714566987717806.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 4, 2015 at 12:06 PM, David Miller <davem@davemloft.net> wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Fri, 04 Dec 2015 20:59:05 +0100
>
>> Yes, I agree, I am totally with you here. If generic offloading can be
>> realized by NICs I am totally with you that this should be the way to
>> go. I don't see that coming in the next (small number of) years, so I
>> don't see a reason to stop this patchset.
>
> If I just apply this and say "yeah ok", the message is completely lost
> and your prediction about "small number of years" indeed will occur.

It is going to take several years regardless.  It isn't as if any of
these manufacturers can spin a design overnight.  It would likely take
a few years even if they suddenly all decided it was an important
feature to have tomorrow.  I suspect we will probably see more cards
with similar offloads long before any updated cards could come out as
there are already likely a number in the pipeline.

> However if I push back hard on this, as I will, then the message has
> some chance of seeping back to the people designing these chips.
>
> So that's what I'm going to do, like it or not.

The problem is the Linux kernel itself doesn't hold much sway over
hardware manufacturers.  A push back on something like this means they
will just bypass the upstream kernel entirely and only support this
type of offload out-of-tree on Linux or in DPDK.

If you are actually wanting to see the manufacturers change their
habits then the consumers of said cards really need to push back on
this kind of stuff.  As the saying goes money talks, B.S. walks.

> Or can someone convince me that someone who understand this stuff
> is telling the hardware guys to universally put 2's complement
> checksums into the descriptors?
>
> Who is doing that at each and every prominent ethernet hardware
> verndor?
>
> Who?

I actually tried to push the generic checksum idea for fm10k back
during hardware development but ended up losing that battle.  The
problem is you have to have some customer willing to spend the cash in
order to get a feature, and the fact is nobody other than Tom has been
pushing for this.  If it was one of Tom's employer, either Google or
Facebook, that had been telling manufacturers that they wouldn't buy
their product unless it had the feature then you can bet they would
have changed their tune.

If you want to push the manufacturers to change you basically need to
have someone put out some sort of marketable data on how a 1's
compliment checksum approach is superior to the current solution that
just indicates if the checksum is valid.  The problem is I haven't
seen anything like that so either this is due to nobody providing a
part that actually takes this approach, or because the approach is not
superior in terms of performance.  The test that should demonstrate
the superiority of using the 1's compliment checksum would be
something like having a number of VXLAN tunnel ports that exceed the
capabilities of the port filters for a given netdev.  With that you
would have the 1's compliment competing essentially against no offload
at all.

> If I get silence, or some vague non-specific response, then I'm going
> to hold my ground and keep pushing back on this stuff.

Trying to get driver developers to change this is far too late in the
process.  In many cases they hold little sway on the hardware design
which was likely locked down a year or more ago.  It is just preaching
to the choir as I am sure they have plenty of other parts of the
hardware implementation they are not happy with as well.

If anything I would say we need to be able to support the existing
hardware that has some number of filters that will identify these
tunnels via some form of ntuple filter.  The fact is there are already
5 different drivers that do this for VXLAN using vxlan_get_rx_port, I
suspect we will probably see others popping up soon to support GENEVE
and VXLAN-GPE.  By providing support for the existing hardware we can
at least let people make use of their hardware features without having
to circumvent the kernel.

- Alex
