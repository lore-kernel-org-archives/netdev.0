From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: make TCP quick ACK behavior modifiable
Date: Tue, 24 Aug 2010 00:01:29 +0200
Message-ID: <20100823220129.GB2745@nuttenaction>
References: <1282590037-18566-1-git-send-email-hagen@jauu.net>
 <1282596243.2378.327.camel@edumazet-laptop>
 <AANLkTimWaULcbxkUh5aCsM+6fWPaTM8CkZZh2hB_cQ3-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	acme@redhat.com, Stephen Hemminger <shemminger@vyatta.com>
To: Chris Snook <chris.snook@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:48144 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752907Ab0HWWBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 18:01:37 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTimWaULcbxkUh5aCsM+6fWPaTM8CkZZh2hB_cQ3-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Chris Snook | 2010-08-23 17:10:19 [-0400]:

>A year and a half ago, we merged a patch to tune the delayed ack
>behavior.  While the proof of concept was a sysctl interface that a
>relative novice to the TCP code like myself could write, the consensus
>was that we already had a glut of TCP sysctls, and there was a
>potential benefit to doing it on a per-route basis, so we could both
>make the feature more flexible and avoid sysctl pollution by making it
>a per-route tunable.  I think all of the same arguments apply to this
>feature, as well as the argument that it surely makes sense to be
>tuning delayed ack and quick ack in the same place.  I'm CCing acme,
>because he wrote the final patch.

Chris, but I don't support the argument to do this on a per path basis. Why? I
mean it makes sense for RTT, IW and other variables. But quick ack is at
application level and it makes no sense at a per path level. And yes there are
too many sysctl knobs but should we restrict ourself because of this argument?
I mean there are some knobs which are more _special_ then this knob.

The best mechanism is to automatically detect this but it is impossible if the
server had no change to reply. Therefore the idea of disabling the quick ack
mechanism for the _first_ ACK packet, analyze the flow and categorize to bulk
or interactive. But this is another topic and not trivial.

Hagen

