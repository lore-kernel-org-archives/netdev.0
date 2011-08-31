From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: BQL crap and wireless
Date: Wed, 31 Aug 2011 15:48:10 -0400
Message-ID: <20110831194810.GD2474@tuxdriver.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <therbert@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Andrew McGregor <andrewmcgr@gmail.com>,
	Matt Smith <smithm@qca.qualcomm.com>,
	Kevin Hayes <hayes@qca.qualcomm.com>,
	Dave Taht <dave.taht@gmail.com>,
	Derek Smithies <derek@indranet.co.nz>, netdev@vger.kernel.org,
	bloat@bufferbloat.net
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51342 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041Ab1HaUAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 16:00:30 -0400
Content-Disposition: inline
In-Reply-To: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2011 at 04:27:22PM -0700, Luis R. Rodriguez wrote:
> I've just read this thread:
> 
> http://marc.info/?t=131277868500001&r=1&w=2
> 
> Since its not linux-wireless I'll chime in here. It seems that you are
> trying to write an algorithm that will work for all networking and
> 802.11 devices. For networking is seems tough given driver
> architecture and structure and the hope that all drivers will report
> things in a fairly similar way. For 802.11 it was pointed out how we
> have varying bandwidths and depending on the technology used for
> connection (AP, 802.11s, IBSS) a different number of possible peers
> need to be considered. 802.11 faced similar algorithmic complexities
> with rate control and the way Andrew and Derek resolved this was to
> not assume you could solve this problem and simply test out the water
> by trial and error, that gave birth to the minstrel rate control
> algorithm which Felix later rewrote for mac80211 with 802.11n support
> [1]. Can the BQL algorithm make use of the same trial and error
> mechanism and simply try different values and and use EWMA [2] to pick
> the best size for the queue ?
> 
> [1] http://wireless.kernel.org/en/developers/Documentation/mac80211/RateControl/minstrel
> [2] http://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average
> 
>   Luis

Since Luis has stirred things up, I took the liberty of adding Tom's
BQL series to the debloat-testing tree:

	git://git.infradead.org/debloat-testing.git

I'm not sure how well BQL will interact with my eBDP-inspired hack,
debloat-testing commit d2566a176589775cb3a1de4fade972aa62d551ff
("mac80211: implement eBDP algorithm to fight bufferbloat").  So if
anyone wants to try enabling a wireless driver for BQL, you might
consider reverting that patch or at least testing without it.

<shameless plug>
And, of course, don't forget to come to the Bufferbloat and Networking
track at Linux Plumbers Conference next week in Santa Rosa, CA! :-)
</shameless plug>

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
