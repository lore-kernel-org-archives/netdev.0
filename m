From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: routing policy based on u32 classifier
Date: Tue, 11 Dec 2007 12:11:37 +0100
Message-ID: <BAY103-DAV209F85975B7DFE5528959FB2640@phx.gbl>
References: <BAY103-DAV51710C05B584C53DED66DB26B0@phx.gbl> <5A630F46702DD1498FFD48394B4A664C347275DD@john.ad.clarku.edu> <BAY103-DAV999F982646869B2E4AABAB26B0@phx.gbl> <5A630F46702DD1498FFD48394B4A664C347275DE@john.ad.clarku.edu> <BAY103-DAV58E11F167187474762928B26B0@phx.gbl> <5A630F46702DD1498FFD48394B4A664C347275E0@john.ad.clarku.edu>
Cc: <netdev@vger.kernel.org>
To: "Brian S Julin" <BJulin@clarku.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s4.bay0.hotmail.com ([65.54.246.140]:31547 "EHLO
	bay0-omc2-s4.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751136AbXLKLNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 06:13:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian S Julin wrote:

> Marco wrote:
>
>> Brian S Julin wrote:
>>> Almost clear... why can you not just add "src <ADSL
>>> IP>" to the fwmark
>>> route to set the default source address for locally
>>> originating
>>> packets?
>>
>> IIRC, it doesn't work because netfilter isn't called in
>> ip source address selection.
>
> Ah I see. Referring to this diagram...
>
> http://www.shorewall.net/images/Netfilter.png
>
> ...and to many people I see posting about similar issues,
> you are correct in that. A process socket cannot default to
> the correct (final) source address to use if there is a
> fwmark
> rule as it stands.
>
> I'll take a wild guess and conjecture that the reason fwmark
> rules work at all for output routing is that applying a
> fwmark on OUTPUT/mangle constitutes "changing the packet"
> and qualifies it for the NAT reroute. But by the time a
> packet gets sent the source address has already been chosen.
>
> About the only suggestion I can make is that "dumb nat"
> might be more elegant if you are not already using it,
> and looking into getting squid to explicitly set its
> source address.

my solution is cleaner :-) the kernel select the ip for
squid and then it get SNATed.
Thanks for the feedback.

> In fact it may be the case with some daemons
> that even if this were fixed inside the kernel, they will
> ignore the source address configured kernel side because they
> explicitly set it (usually by a reverse of their "Listen"
> configuration.) It's likely that this could be fixed and
> squid require NAT still. Perhaps the best solution is
> for individual daemons to be given configuration options
> telling them what source addresses to use.
>
> Has anyone worked up a patch already to do this kernel
> side? I could see it being fairly complicated. You
> would have to hand the packet directly to netfilter, then
> have netfilter perform a first-run RPDB lookup only for
> packets where it needs to (or packets which it decides
> not to touch) and then a second RPDB lookup if the
> packet is modified. Might speed things up a bit for
> some cases as a side benefit but worth it? I don't
> know.
>


