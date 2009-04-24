From: David Miller <davem@davemloft.net>
Subject: Re: about latencies
Date: Thu, 23 Apr 2009 17:04:08 -0700 (PDT)
Message-ID: <20090423.170408.228280954.davem@davemloft.net>
References: <49F0E579.5030200@cosmosbay.com>
	<alpine.WNT.2.00.0904231520300.5352@jbrandeb-desk1.amr.corp.intel.com>
	<49F0F49A.1050609@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jesse.brandeburg@intel.com, cl@linux-foundation.org,
	netdev@vger.kernel.org, mchan@broadcom.com,
	bhutchings@solarflare.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41063
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750798AbZDXAEQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 20:04:16 -0400
In-Reply-To: <49F0F49A.1050609@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 24 Apr 2009 01:07:06 +0200

> Brandeburg, Jesse a =E9crit :
>> On Thu, 23 Apr 2009, Eric Dumazet wrote:
>>> We could improve this.
>>>
>>> 1) dst_release at xmit time, should save a cache line ping-pong on =
general case
>>> 2) sock_wfree() in advance, done at transmit time (generally the th=
read/cpu doing the send)
>>=20
>> how much does the effect socket accounting?  will the app then fill =
the=20
>> hardware tx ring all the time because there is no application thrott=
ling=20
>> due to delayed kfree?
>=20
> tx ring is limited to 256 or 512 or 1024 elements, but yes this might
> defeat udp mem accounting on sending side, unless using qdiscs...

I'm pretty sure you really can't do this.  It's been suggested
countless times in the past.

The whole point of the socket send buffer limits is to eliminate
the situation where one socket essentially hogs the TX queue of
the device.
