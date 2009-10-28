From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iproute uses too small of a receive buffer
Date: Wed, 28 Oct 2009 08:52:57 +0100
Message-ID: <4AE7F859.7020105@gmail.com>
References: <4AE77F64.3090302@candelatech.com> <20091027162434.6dc31b2d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37593 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932543AbZJ1Hwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 03:52:55 -0400
In-Reply-To: <20091027162434.6dc31b2d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
>=20
> Just having larger buffer isn't guarantee of success. Allocating
> a huge buffer is not going to work on embedded.
>=20

Please note we do not allocate a big buffer, only allow more small skbs
to be queued on socket receive queue.

If memory is not available, skb allocation will eventually fail
and be reported as well, embedded or not.

I vote for allowing 1024*1024 bytes instead of 32768,
and eventually user should be warned that it is capped by=20
/proc/sys/net/core/rmem_max


> Why not have it continue after one error.

Yes, but caller of 'ip monitor' just restart it anyway
