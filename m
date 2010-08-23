From: Chris Snook <chris.snook@gmail.com>
Subject: Re: [PATCH] tcp: make TCP quick ACK behavior modifiable
Date: Mon, 23 Aug 2010 18:19:45 -0400
Message-ID: <AANLkTinb_tjcz=AF1-2i7MK=Bgm7aEtozjb3Ds0swi8q@mail.gmail.com>
References: <1282590037-18566-1-git-send-email-hagen@jauu.net>
 <1282596243.2378.327.camel@edumazet-laptop> <AANLkTimWaULcbxkUh5aCsM+6fWPaTM8CkZZh2hB_cQ3-@mail.gmail.com>
 <20100823220129.GB2745@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	acme@redhat.com, Stephen Hemminger <shemminger@vyatta.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:50442 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754856Ab0HWWUH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 18:20:07 -0400
Received: by gyd8 with SMTP id 8so2334362gyd.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 15:20:06 -0700 (PDT)
In-Reply-To: <20100823220129.GB2745@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 23, 2010 at 6:01 PM, Hagen Paul Pfeifer <hagen@jauu.net> wr=
ote:
> * Chris Snook | 2010-08-23 17:10:19 [-0400]:
>
>>A year and a half ago, we merged a patch to tune the delayed ack
>>behavior. =A0While the proof of concept was a sysctl interface that a
>>relative novice to the TCP code like myself could write, the consensu=
s
>>was that we already had a glut of TCP sysctls, and there was a
>>potential benefit to doing it on a per-route basis, so we could both
>>make the feature more flexible and avoid sysctl pollution by making i=
t
>>a per-route tunable. =A0I think all of the same arguments apply to th=
is
>>feature, as well as the argument that it surely makes sense to be
>>tuning delayed ack and quick ack in the same place. =A0I'm CCing acme=
,
>>because he wrote the final patch.
>
> Chris, but I don't support the argument to do this on a per path basi=
s. Why? I
> mean it makes sense for RTT, IW and other variables. But quick ack is=
 at
> application level and it makes no sense at a per path level. And yes =
there are
> too many sysctl knobs but should we restrict ourself because of this =
argument?
> I mean there are some knobs which are more _special_ then this knob.
>
> The best mechanism is to automatically detect this but it is impossib=
le if the
> server had no change to reply. Therefore the idea of disabling the qu=
ick ack
> mechanism for the _first_ ACK packet, analyze the flow and categorize=
 to bulk
> or interactive. But this is another topic and not trivial.

Just because we've allowed stupid TCP sysctls in the past does not
mean we should continue to do so now.  We recently made delayed ack a
per-route tunable, so consistency would suggest we do the same here.
Per-route tunables are more flexible, and as with the delayed ack
patch, there are use cases where that granularity gives a clear
advantage over a sysctl.  For example, you may want to disable quick
ack on a high-MTU path and enable it on a low-MTU path.

If you need a hint for how to implement the per-route tunable, look
for the delayed ack patch from early 2009.

-- Chris
