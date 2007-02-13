From: John Heffner <jheffner@psc.edu>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Tue, 13 Feb 2007 14:54:45 -0500
Message-ID: <45D21785.5060105@psc.edu>
References: <20070212191101.GP25760@galon.ev-en.org> <20070212.122058.63127043.davem@davemloft.net> <20070212221241.GQ25760@galon.ev-en.org> <20070212.145351.35661569.davem@davemloft.net> <20070213095613.GR25760@galon.ev-en.org> <649aecc70702130849s6f70bf37y1f8177060d433ce0@mail.gmail.com> <20070213174216.GS25760@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Baruch Even <baruch@ev-en.org>, SANGTAE HA <sangtae.ha@gmail.com>,
	David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:65526 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750859AbXBMTy6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:54:58 -0500
In-Reply-To: <20070213174216.GS25760@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This isn't really a reply to anyone in particular, but I wanted to touch 
on a few points.


>> Reno. As Windows decided to go with "Compound TCP", why we want to
>> back to 80's algorithm?

It's worth noting that Microsoft is not using Compound TCP by default, 
except in Beta versions so they can get more experience with it.  It is 
available to turn on in production versions, but Reno is still default. 
  Take this how you will, but that's the current state of affairs.


> I fail to see how Microsoft should be the reason for anything, if
> anything Linux started the arms race.

I'd like to put to bed this notion of an arms race.  A number of people 
have accused Linux and Windows of competing with each other to be more 
aggressive, which is just not the case.  The use of non-standard 
congestion control algorithms is due to a real need to fill underused 
large pipes.  In fact, if Linux or Windows stomped on top of other TCPs 
in production, it would lead to a bad reputation for the one doing the 
stomping, and is something everyone is eager to avoid.  It would be 
easier to design an extremely aggressive control algorithm.  The hard 
work is in achieving the desired properties of fairness, stability, 
etc., in addition to high utilization.

Some care has been taken (okay, with varying success) in designing each 
of the default candidate algorithms to avoid harming standard Reno-style 
flows under "normal" conditions.  If an algorithms meets this 
requirement, then there's almost no reason at this point not to use it. 
  The main issue for the future is dealing with the interaction between 
various (possibly unknown) congestion control algorithms.  From an 
academic point of view, it's very difficult to say anything about how 
they might interact.  At least it's more difficult than modeling how 
flows using a single algorithm interact with each other.  This is 
something of a concern, but we must weigh this against the pressing 
demand for something better than reno.  Further, there's all sorts of 
traffic out there on the Internet with varying responsiveness, as there 
is no enforcement of any particular model of congestion control.  This 
must be taken into account, regardless of what Linux chooses as its 
default at any point in time.

   -John
