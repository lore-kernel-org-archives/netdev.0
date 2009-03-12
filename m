From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to
	submit to upper layer
Date: Thu, 12 Mar 2009 14:08:26 +0000
Message-ID: <1236866906.3221.11.camel@achroite>
References: <1236761624.2567.442.camel@ymzhang>
	 <877i2wfh1l.fsf@basil.nowhere.org>  <1236845792.2567.484.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, herbert@gondor.apana.org.au,
	jesse.brandeburg@intel.com, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:50264 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752942AbZCLOIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 10:08:39 -0400
In-Reply-To: <1236845792.2567.484.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-03-12 at 16:16 +0800, Zhang, Yanmin wrote:
> On Wed, 2009-03-11 at 12:13 +0100, Andi Kleen wrote:
[...]
> >  and just use the hash function on the
> > NIC.
> Sorry. I can't understand what the hash function of NIC is. Perhaps N=
IC hardware has something
> like hash function to decide the RX queue number based on SRC/DST?

Yes, that's exactly what they do.  This feature is sometimes called
Receive-Side Scaling (RSS) which is Microsoft's name for it.  Microsoft
requires Windows drivers performing RSS to provide the hash value to th=
e
networking stack, so Linux drivers for the same hardware should be able
to do so too.

> >  Have you considered this for forwarding too?
> Yes. originally, I plan to add a tx_num under the same sysfs director=
y, so admin could
> define that all packets received from a RX queue should be sent out f=
rom a specific TX queue.

The choice of TX queue can be based on the RX hash so that configuratio=
n
is usually unnecessary.

> So struct sk_buff->queue_mapping would be a union of 2 sub-members, r=
x_num and tx_num. But
> =EF=BB=BFsk_buff->queue_mapping is just a u16 which is a small type. =
We might use the most-significant
> bit of =EF=BB=BFsk_buff->queue_mapping as a flag as rx_num and tx_num=
 wouldn't exist at the
> same time.
>=20
> >  The trick here would
> > be to try to avoid reordering inside streams as far as possible,
> It's not to solve reorder issue. The start point is 10G NIC is very f=
ast. We need some cpu
> work on packet receiving dedicately. If they work on other things, NI=
C might drop packets
> quickly.

Aggressive power-saving causes far greater latency than context-
switching under Linux.  I believe most 10G NICs have large RX FIFOs to
mitigate against this.  Ethernet flow control also helps to prevent
packet loss.

> The sysfs interface is just to facilitate NIC drivers. If there is no=
 the sysfs interface,
> driver developers need implement it with parameters which are painful=
=2E
[...]

Or through the ethtool API, which already has some multiqueue control
operations.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

