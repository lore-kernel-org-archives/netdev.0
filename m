From: Nick Carter <ncarter100@gmail.com>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Wed, 29 Jun 2011 23:46:03 +0100
Message-ID: <BANLkTi=4-xYNyaBOzeL04VioK8D0Q8secg@mail.gmail.com>
References: <20110628150257.GB126252@jupiter.n2.diac24.net>
	<20110628081015.1b06a3f0@nehalam.ftrdhcpuser.net>
	<20110628160018.GC126252@jupiter.n2.diac24.net>
	<BANLkTikDqjErqBmfwrN6SJPgPjmmMfJw7g@mail.gmail.com>
	<20110628185811.GA2121496@jupiter.n2.diac24.net>
	<BANLkTi=goXU4SpP6dxX9C+YeLcVMEkcKHw@mail.gmail.com>
	<20110628202200.GB2121496@jupiter.n2.diac24.net>
	<BANLkTim1owW7iMS3hgKhm7DzTzE4X-jxHA@mail.gmail.com>
	<20110628210434.GD2121496@jupiter.n2.diac24.net>
	<BANLkTikN_TPPcyywVT5W9CrGAFJX8qQiyQ@mail.gmail.com>
	<20110628214637.GE2121496@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:53913 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753340Ab1F2WqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 18:46:04 -0400
Received: by pzk26 with SMTP id 26so1496692pzk.10
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2011 15:46:03 -0700 (PDT)
In-Reply-To: <20110628214637.GE2121496@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 June 2011 22:46, David Lamparter <equinox@diac24.net> wrote:
> On Tue, Jun 28, 2011 at 10:22:53PM +0100, Nick Carter wrote:
>> > I beg to differ, there very much is. You never ever ever want to be
>> > running STP with 802.1X packets passing through... some client will shut
>> > down your upstream port, your STP will break and you will die in a fire.
>> >
>> > The general idea, though, is that a STP-enabled switch is an intelligent
>> > switch. And an intelligent switch can speak all those pesky small
>> > side-dish protocols.
> [...]
>> >> > (Some quick googling reveals that hardware switch chips special-drop
>> >> > 01:80:c2:00:00:01 [802.3x/pause] and :02 [802.3ad/lacp] and nothing
>> >> > else - for the dumb ones anyway. It also seems like the match for pause
>> >> > frames usually works on the address, not on the protocol field like we
>> >> > do it...)
>> >> 'Enterprise' switches drop :03 [802.1x]
>> >
>> > They also speak STP, see above about never STP+1X :)
>> But if you turn off STP they wont start forwarding 802.1x.
>
> Yes, hence my suggestion to have a knob for all of the link-local
> ethernet groups. (Which I'm still not actually endorsing, just placing
> the idea)
>
>> Also having STP on and forwarding 802.1x would be useful (but
>> non-standard) in some cheap redundant periphery switches, connecting
>> to a couple of 'core' switches acting as 802.1x authenticators.
>
> That wouldn't really make much sense since those central 802.1X
> authenticators wouldn't be able switch the client-facing ports on and
> off.
Although its non standard, it is common for authenticators to do
802.1X per source mac rather than per port.  Also the central
authenticator ports can be routed not bridged.  So i dont think you
can rule out the "STP on plus 802.1x being forwarded" requirement.

> Instead, you now have to (1) disable the port switching to make
> sure your upstreams stay on and (2) deal with 802.1X clients being
> re"routed" by STP to different authenticators that don't know them.
Well if the authenticators are pointed at a remote ACS then they will
know them.  And again even though non-standard, 802.1X 'mac move'
functionality exists.
Nick
>
>
> -David
>
>
