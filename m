From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: [RFC v1] hand off skb list to other cpu to submit to upper
	layer
Date: Thu, 05 Mar 2009 09:04:36 +0800
Message-ID: <1236215076.2567.105.camel@ymzhang>
References: <1235546423.2604.556.camel@ymzhang>
	 <20090224.233115.240823417.davem@davemloft.net>
	 <1236158868.2567.93.camel@ymzhang>
	 <20090304.013937.129768263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:55810 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750775AbZCEBFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 20:05:02 -0500
In-Reply-To: <20090304.013937.129768263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-03-04 at 01:39 -0800, David Miller wrote:
> From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
> Date: Wed, 04 Mar 2009 17:27:48 +0800
>=20
> > Both the new skb_record_rx_queue and current kernel have an
> > assumption on multi-queue. The assumption is it's best to send out
> > packets from the TX of the same number of queue like the one of RX
> > if the receved packets are related to the out packets. Or more
> > direct speaking is we need send packets on the same cpu on which we
> > receive them. The start point is that could reduce skb and data
> > cache miss.
>=20
> We have to use the same TX queue for all packets for the same
> connection flow (same src/dst IP address and ports) otherwise
> we introduce reordering.
> Herbert brought this up, now I have explicitly brought this up,
> and you cannot ignore this issue.
Thanks. =EF=BB=BFStephen Hemminger brought it up and explained what reo=
rder
is. I answered in a reply (sorry for not clear) that mostly we need spr=
ead
packets among RX/TX in a 1:1 mapping or N:1 mapping. For example, all p=
ackets
received from RX 8 will be spreaded to TX 0 always.


>=20
> You must not knowingly reorder packets, and using different TX
> queues for packets within the same flow does that.
Thanks for you rexplanation which is really consistent with =EF=BB=BFSt=
ephen's speaking.


