From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] [PATCH] net: Add support for ndo_select_queue() functions
 to cache the queue mapping
Date: Thu, 28 Jan 2010 10:00:11 -0800
Message-ID: <20100128100011.2b624a9e@nehalam>
References: <1264700317.2783.15.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47042 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754082Ab0A1SAd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 13:00:33 -0500
In-Reply-To: <1264700317.2783.15.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Jan 2010 17:38:37 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:

> =EF=BB=BFWe think it's worth matching up RX and TX queue selection fo=
r a socket
> when the queues share an interrupt.  Currently the default TX queue
> selection is unlikely to match RX queue selection.  TX queue selectio=
nc
> can be overridden by the driver to match RX queue selection, but at t=
he
> expense of caching.  We found that without caching the cost of
> recalculating the the hash in software for each packet outweighed the
> benefit of good queue selection.

Will this work with RPS and device driver hashing?
I am thinking of the problem where the hardware hash function is
Toeplitz (per NDIS spec), and the software hash function is Jhash
(what kernel uses because it is cheaper).

Therefore the transmit hash and receiver hash will be different.


--=20
