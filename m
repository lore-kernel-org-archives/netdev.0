From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v4 0/5] net: Unified offload configuration
Date: Mon, 7 Feb 2011 23:49:37 +0100
Message-ID: <20110207224937.GA32549@rere.qmqm.pl>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl> <20110207.133721.48496023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51394 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755129Ab1BGWtj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Feb 2011 17:49:39 -0500
Content-Disposition: inline
In-Reply-To: <20110207.133721.48496023.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 07, 2011 at 01:37:21PM -0800, David Miller wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Date: Thu,  3 Feb 2011 15:21:21 +0100 (CET)
> > Here's a v4 of the ethtool unification patch series.
[cut list]
> After these changes the ethtool output is now inaccurate for
> RX checksumming.
>=20
> Before:
>=20
> davem@maramba:~$ /usr/sbin/ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: on
> tx-checksumming: on
[...]
=20
> After:
>=20
> davem@maramba:~$ /usr/sbin/ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: off
> tx-checksumming: on
[...]
>=20
> If the issue is that you require driver or ethtool utility changes in
> order for things to keep working properly, then that is not
> acceptable.

> I'm reverting all of these changes, resubmit them when you have them
> in a state such that no regressions will be introduced.

What driver did you get this output from?  All drivers that implement
set_rx_csum also implement their own get_rx_csum and so should not be
affected by patch #4. For others that don't implement get_rx_csum
rx-checksumming status is unreliable. Looking at random drivers:
 - via-rhine: will advertise rx-checksumming when it doesn't support
	it (as a side effect of hardware workaround - checksum in driver)
 - sunhme: has no way to disable rx- and tx-checksumming so was
	correctly showing rx-checksumming enabled
 - 8139too: will show rx-checksumming enabled but doesn't support it
	(side effect of hardware workaround - checksumming in driver)

I wouldn't be suprised if there was a driver which doesn't advertise
RX checksumming but use it anyway.

So yes - this patchset uncovers bugs in drivers. I'll see how can I
make the RXCSUM patch retain the previous behaviour for this case.

Best Regards,
Micha=B3 Miros=B3aw
