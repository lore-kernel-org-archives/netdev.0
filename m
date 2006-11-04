From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [patch] d80211: use pfifo_qdisc_ops ratherthand80211-specificqdisc
Date: Fri, 3 Nov 2006 18:20:35 -0800
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F018B603D@dhost002-46.dex002.intermedia.net>
References: <1162595228.24673.1.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Stephen Hemminger" <shemminger@osdl.org>,
	"Christoph Hellwig" <hch@infradead.org>,
	"James Ketrenos" <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Patrick McHardy" <kaber@trash.net>,
	"David Kimdon" <dwhedon@devicescape.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:52390 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751408AbWKDCUT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 21:20:19 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1162595228.24673.1.camel@johannes.berg>
To: "Johannes Berg" <johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I guess right now when you transmit on the master device frames are only
accepted with a cookie and all that info in the CB. It would work just
as well to move that info from the CB and into a protocol header. It
would also make it easier to expand the info without the size constraint
of the CB. Same could apply on receive.

Simon 

-----Original Message-----
From: Johannes Berg [mailto:johannes@sipsolutions.net] 
Sent: Friday, November 03, 2006 3:07 PM
To: Simon Barber
Cc: Stephen Hemminger; Christoph Hellwig; James Ketrenos; John W.
Linville; Jeff Garzik; Patrick McHardy; David Kimdon;
netdev@vger.kernel.org
Subject: RE: [patch] d80211: use pfifo_qdisc_ops
ratherthand80211-specificqdisc

On Fri, 2006-11-03 at 11:23 -0800, Simon Barber wrote:
> I would
> think the master device is the perfect place to do packet capture,

Sort of. Since it'll be an 802.11 protocol thing, you won't be getting
any signal strength information etc. You really do need that.

>  and
> raw packet transmission.

Same here, you really do want to be able to submit a frame with the
bitrate to use etc. All not part of 802.11.

All the meta info you want from RX or need for proper TX cannot be
transported over that master netdev since it'll have a proper 802.11
protocol, so it's pretty much useless.

johannes
