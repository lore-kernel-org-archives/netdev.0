From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Thu, 27 May 2010 09:08:27 +0200
Message-ID: <20100527070827.GB2728@nuttenaction>
References: <20100526212745.GC24615@basil.fritz.box>
 <20100526.151014.70204145.davem@davemloft.net>
 <20100526231512.GD2684@nuttenaction>
 <20100526.200443.232751390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:35511 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750967Ab0E0HIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 03:08:31 -0400
Content-Disposition: inline
In-Reply-To: <20100526.200443.232751390.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller | 2010-05-26 20:04:43 [-0700]:

>You're asking about a network level issue in terms of what can be done
>on a local end-node.

No, I *write* about network level issues, this is the important item in my
mind.  It is about network stability and network fairness. The lion share of
TCP algorithm are drafted to guarantee _network fairness and network stability_.

And by the way, the IETF (and our) paradigm is still to shift functionality to
end hosts - not into network core. "The Rise of the stupid network" [1] is
still a paradigm that is superior to the alternative where vendors put their
proprietary algorithms into the network and change the behavior in a
uncontrollable fashion.

>All an end-node can do is abide by congestion control rules and respond
>to packet drops, as has been going on for decades.

Right, and this will be reality for the next decades (at least for TCP;
maybe backed by ECN).

>People have basically (especially in Europe) given up on crazy crap
>like RSVP and other forms of bandwidth limiting and reservation.  They
>just oversubscribe their links, and increase their capacity as traffic
>increases dictate.  It just isn't all that manageable to put people's
>traffic into classes and control what they do on a large scale.
>
>I'm also skeptical about those who say the fight belongs squarely at
>the end nodes.  If you want to control the network traffic of the
>meeting point of your dumbbell, you'll need a machine there doing RED
>or traffic limiting.  End-host schemes simply aren't going to work
>because I can just add more end-hosts to reintroduce the problem.

I am not happy with this statement. This differs from the previous paragraph
where you complain about intelligent network components. Davem until these
days the routers do exactly this, they do RED/WRED whatever and signal to the
producer to reduce their bandwidth.

And this is the most important aspect in this email: core network components
rely on end hosts to behave in a fair manner. Disable Slow Start/Congestion
Avoidance and the network will instantly collapse (mmh, net-next? ;-)

The mechanism as proposed in the patch is not fair. There are a lot of
publications available that analyse the impact CWND in great detail as well as
several RFC that talk about the CWND.

>The dumbbell situation is independant of the end-node issues, that's
>all I'm really saying.

Davem, I know that you are a good guy and worries about fairness aspects
really well. I wrote this email to popularize fairness and network stability
aspects to the broad audience.

Hagen


[1] http://isen.com/stupid.html


>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Die Zensur ist das lebendige Gestaendnis der Grossen, dass sie 
nur verdummte Sklaven treten, aber keine freien Voelker regieren koennen.
- Johann Nepomuk Nestroy

