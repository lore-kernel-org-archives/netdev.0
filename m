From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/5] net: Unified offload configuration
Date: Mon, 07 Feb 2011 13:37:21 -0800 (PST)
Message-ID: <20110207.133721.48496023.davem@davemloft.net>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47715
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753313Ab1BGVgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 16:36:46 -0500
In-Reply-To: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu,  3 Feb 2011 15:21:21 +0100 (CET)

> Here's a v4 of the ethtool unification patch series.
>=20
> What's in it?
>  1:
> 	the patch - implement unified ethtool setting ops
>  2..3:
> 	implement interoperation between old and new ethtool ops
>  4:
> 	include RX checksum in features and plug it into new framework
>  5:
> 	convert loopback device to new framework

After these changes the ethtool output is now inaccurate for
RX checksumming.

Before:

davem@maramba:~$ /usr/sbin/ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: on
large receive offload: off
davem@maramba:~$=20

After:

davem@maramba:~$ /usr/sbin/ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: off
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: on
large receive offload: off

If the issue is that you require driver or ethtool utility changes in
order for things to keep working properly, then that is not
acceptable.

I'm reverting all of these changes, resubmit them when you have them
in a state such that no regressions will be introduced.

Thanks.
