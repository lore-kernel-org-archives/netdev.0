From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: niu interface automatically goes up then down
Date: Thu, 10 Jan 2013 02:52:24 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1301100231320.29960@nerf07.vanv.qr>
References: <alpine.LNX.2.01.1301092342290.21351@nerf07.vanv.qr> <CAGRGNgWqweBphbr+rpTZ2Fe=yLG_xNSvS4sf8XteoCiAx8b81A@mail.gmail.com> <alpine.LNX.2.01.1301100134300.29388@nerf07.vanv.qr> <CAGRGNgX6u=Q4_8pFhLNHDQYRCv1m3ULBgyc+wA=+_KDjDDbSjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>,
	sparclinux@vger.kernel.org
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:54431 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932491Ab3AJBw1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 20:52:27 -0500
In-Reply-To: <CAGRGNgX6u=Q4_8pFhLNHDQYRCv1m3ULBgyc+wA=+_KDjDDbSjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2013-01-10 02:27, Julian Calaby wrote:
>
>> The issue is not pressing, since it's just service processors
>> which are connected.
>
>Ok, I'm guessing that this is production so heavy debugging isn't
>going to happen.

No production, free to toy.

>I'm out of ideas. Tag?

Here is a fun fact. If I disable autonegotiation (via ethtool) on the 
link on the niu side, the remote side will deassert the carrier and 
won't return it until autoneg is turned on again.

In fact, if I do `ethtool -s eth7 autoneg off; ethtool -s eth7 autoneg 
on;`, it will take a good exact second (~1.000400 s) for the HW to 
reestablish an autonegotiated link. This delay is of the same magnitude 
and value as when the link bounces on its own.
Hypothesis: maybe the niu HW drops autoneg for a splitsecond (or it 
gets lost due to some other reason), causing the observed bounces.
