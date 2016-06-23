From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Thu, 23 Jun 2016 04:10:53 +0000
Message-ID: <CO2PR11MB0088B3C577EC110B845C17B3972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com>
 <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com>
 <1466638292.6850.94.camel@edumazet-glaptop3.roam.corp.google.com>,<CAKgT0Uex41aBJX84we2gxNGw6M4s5xGEPnDkGehTZkEE+i+Jhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
Received: from mail-by2on0104.outbound.protection.outlook.com ([207.46.100.104]:63120
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750785AbcFWEK6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 00:10:58 -0400
In-Reply-To: <CAKgT0Uex41aBJX84we2gxNGw6M4s5xGEPnDkGehTZkEE+i+Jhw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Claiming that hardware assist GRO is not possible is a plain mantra.

> I have no issue claiming hardware assist GRO is possible.=A0 My probl=
em
> is saying that the GRO feature flag can be used to enable it.=A0 I wo=
uld
> argue that any packet aggregation at the device or driver level is LR=
O
> regardless of how close it comes to GRO feature wise.=A0 GRO should o=
nly
> be occurring in the receive path after calling the appropriate GRO
> function.=A0 Otherwise it becomes really difficult to work around any
> possible issues that the hardware assisted GRO introduces without
> paying a huge penalty.=A0 We need to keep these feature flags separat=
e.
> I thought that was the whole reason why we have the distinction
> between LRO and GRO in the first place.

Then again, if you're basically saying every HW-assisted offload on
receive should be done under LRO flag, what would be the use case
where a GRO-assisted offload would help?

I.e., afaik LRO is superior to GRO in `brute force' -
it creates better packed packets and utilizes memory better
[with all the obvious cons such as inability for defragmentation].
So if you'd have the choice of having an adpater perform 'classic'
LRO aggregation or something that resembles a GRO packet,
what would be the gain from doing the latter?
