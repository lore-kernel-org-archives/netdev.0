From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Thu, 23 Jun 2016 04:17:18 +0000
Message-ID: <CO2PR11MB0088949623FA99ED86D33205972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com>
 <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com>
 <1466638292.6850.94.camel@edumazet-glaptop3.roam.corp.google.com>,<CAKgT0Uex41aBJX84we2gxNGw6M4s5xGEPnDkGehTZkEE+i+Jhw@mail.gmail.com>,<CO2PR11MB0088B3C577EC110B845C17B3972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Rick Jones <rick.jones2@hpe.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0103.outbound.protection.outlook.com ([157.56.111.103]:41760
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750811AbcFWERj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 00:17:39 -0400
In-Reply-To: <CO2PR11MB0088B3C577EC110B845C17B3972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Then again, if you're basically saying every HW-assisted offload on
> receive should be done under LRO flag, what would be the use case
> where a GRO-assisted offload would help?

> I.e., afaik LRO is superior to GRO in `brute force' -
> it creates better packed packets and utilizes memory better
> [with all the obvious cons such as inability for defragmentation].
> So if you'd have the choice of having an adpater perform 'classic'
> LRO aggregation or something that resembles a GRO packet,
> what would be the gain from doing the latter?

Just to relate to bnx2x/qede differences in current implementation -
when this GRO hw-offload was added to bnx2x, it has already
supported classical LRO, and due to above statement whenever LRO
was set driver aggregated incoming traffic as classic LRO.
I agree that in hindsight the lack of distinction between sw/hw GRO
was hurting us.

qede isn't implementing LRO, so we could easily mark this feature
under LRO there - but question is, given that the adapter can support
LRO, if we're going to suffer from all the shotrages that arise from
putting this feature under LRO, why should we bother?

You can argue that we might need a new feature bit for control
over such a feature; If we don't do that, is there any gain in all of this?
