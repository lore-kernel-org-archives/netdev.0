From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: inconsistency of ethtool feature names for get vs. set
Date: Thu, 2 Jan 2014 14:40:10 +0200
Message-ID: <CAKoUAr=jm0YP=c=bggOaA1MtK=funkX4WuD+FUVgDPidUi5Xnw@mail.gmail.com>
References: <52C535B9.7080208@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:64278 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbaABMkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 07:40:12 -0500
Received: by mail-wi0-f174.google.com with SMTP id z2so18643771wiv.7
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 04:40:10 -0800 (PST)
In-Reply-To: <52C535B9.7080208@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
3 short comments:

1) This is true also to setting GSO:
ethtool -k enp0s8  | grep generic-segmentation-offload
generic-segmentation-offload: on

ethtool -K enp0s8  generic-segmentation-offload off
ethtool: bad command line argument(s)

and
ethtool -K enp0s8  gso off
works.

and also to setting scatter-gather:
ethtool -k enp0s8  | grep scatter-gather
scatter-gather: off

ethtool -K enp0s8  scatter-gather on
ethtool: bad command line argument(s)

And
ethtool -K enp0s8  sg on
works.

2)
you said:
> ethtool -K eth1  rx-gro on

You can also use:
ethtool -K eth1  gro on


3)
>same problem for rx checksum which is displayed as "rx-checksumming" >by the get (-k)
>but need to be "rx-checksum" for the set (-K) directive.
You can also use:
ethtool -K eth1  rx on
or
ethtool -K eth1  rx off

The same for tx-checksum:
ethtool -K eth1  tx on
or
ethtool -K eth1  tx off

Regards,
Rami Rosen
http://ramirose.wix.com/ramirosen
