From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Tue, 17 May 2011 10:08:09 +0200
Message-ID: <BANLkTimeRLQ0FLASsLE+ZxiXOk4gHt5XFQ@mail.gmail.com>
References: <20110505100506.GA20111@gondor.apana.org.au> <20110516073210.GB6610@redhat.com>
 <20110516080702.GA1857@gondor.apana.org.au> <20110516081841.GA8073@redhat.com>
 <20110516093822.GA2779@gondor.apana.org.au> <20110516094821.GA9427@redhat.com>
 <20110516104309.GA3534@gondor.apana.org.au> <20110516112133.GA11274@redhat.com>
 <20110516121857.GA4495@gondor.apana.org.au> <BANLkTi=7i=AQfPNBEGcLFieaO9wXgBk6rg@mail.gmail.com>
 <20110516224658.GA11157@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Shan Wei <shanwei@cn.fujitsu.com>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:51576 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979Ab1EQII3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 04:08:29 -0400
Received: by qwk3 with SMTP id 3so111209qwk.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 01:08:29 -0700 (PDT)
In-Reply-To: <20110516224658.GA11157@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/17 Herbert Xu <herbert@gondor.apana.org.au>:
> On Mon, May 16, 2011 at 02:24:19PM +0200, Micha=C5=82 Miros=C5=82aw w=
rote:
>> In this case - no. Those messages inform that driver supports more
>> feature combinations than network core and the feature set is reduce=
d
>> because of that.
> The driver should never even claim to support SG/TSO/UFO if it
> does not support checksum. =C2=A0That is the point of the warning.

Not really. The dependency of SG on checksum is in network core code
only, not in the hardware. For TSO/UFO they imply hw checksumming for
the respective protocol, but still theres no point in duplicating
features dependencies in driver code.

In the tun/tap case, by using TUNSETOFFLOAD userspace advertises that
it is willing to receive unchecksummed/TSOed packets from kernel (it
should use TUN_VNET_HDR for this to work correctly unless it doesn't
forward the packets). After the conversion, those offloads can be
disabled by using ethtool even if userspace does support them.
Previously you were able to push offloaded packets to apllications not
prepared for them.

Best Regards,
Micha=C5=82 Miros=C5=82aw
