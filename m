From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Mon, 5 Mar 2012 19:55:03 +0100
Message-ID: <20120305185502.GF3119316@jupiter.n2.diac24.net>
References: <CABBYNZJ-xxQXAx+ecrkVLqmWFaUVqLcQLj0Jxa3McSLnkLJSJw@mail.gmail.com>
 <20120301.170848.432407217191581288.davem@davemloft.net>
 <CABBYNZLwHKd5srzYYzWNL-iaeuH1K31824pY_bjRSbSLkv0QtA@mail.gmail.com>
 <20120302.035509.1994457175982020283.davem@davemloft.net>
 <4F509274.9060302@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	ying.xue@windriver.com, luiz.dentz@gmail.com,
	eric.dumazet@gmail.com, rodrigo.moya@collabora.co.uk,
	javier@collabora.co.uk, lennart@poettering.net,
	kay.sievers@vrfy.org, alban.crequy@collabora.co.uk,
	bart.cerneels@collabora.co.uk, sjoerd.simons@collabora.co.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:33883 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757336Ab2CESzW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 13:55:22 -0500
Content-Disposition: inline
In-Reply-To: <4F509274.9060302@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 02, 2012 at 10:27:16AM +0100, Javier Martinez Canillas wrote:
> Do you think that a simpler AF_UNIX multicast implementation without the
> locking to guarantee order delivery and the flow control that blocks the
> sender can be resend to you to reconsider merging it?

I still don't get how blocking the sender when the receiver doesn't
empty his socket queue can possibly ever be a good idea. All I see is a
very nice way to choke the entire D-Bus from one malicious or broken
app.

Note that originally we were talking about blocking delivery for
_multicast_. In that case you can't even poll on writability on a
granularity finer than group level.

Yet, this still comes up here and there as a requirement for IPC
mechanisms to back D-Bus.

When the buffers at the receiver are fully filled, IMHO that's the point
to cut off the client. If this becomes an issue, the buffers can be
increased in size, but at some point it's a sign that you're using D-Bus
for too much?


-David
