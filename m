From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Fri, 02 Mar 2012 05:13:51 -0800
Message-ID: <1330694031.2469.15.camel@edumazet-laptop>
References: <CABBYNZJ-xxQXAx+ecrkVLqmWFaUVqLcQLj0Jxa3McSLnkLJSJw@mail.gmail.com>
	 <20120301.170848.432407217191581288.davem@davemloft.net>
	 <CABBYNZLwHKd5srzYYzWNL-iaeuH1K31824pY_bjRSbSLkv0QtA@mail.gmail.com>
	 <20120302.035509.1994457175982020283.davem@davemloft.net>
	 <4F509274.9060302@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	ying.xue@windriver.com, luiz.dentz@gmail.com,
	rodrigo.moya@collabora.co.uk, javier@collabora.co.uk,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:56628 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757510Ab2CBNNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 08:13:54 -0500
In-Reply-To: <4F509274.9060302@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 mars 2012 =C3=A0 10:27 +0100, Javier Martinez Canillas a
=C3=A9crit :

> We are the most interested in using a facility already found in the
> kernel, we will try ZeroMQ as Stephen suggested and TIPC but really
> didn't find an IPC mechanism that fits our needs. The most important
> issue right now is the fd passing for D-bus application doing
> out-of-band communication.

Why on earth the needed D-Bus IPC should use a single kernel mechanism =
?

I mean, of course AF_INET cannot pass fd around and never will.
Of course AF_UNIX cannot use multicast and never will.
Of course shared memory wont pass fds around and never will.
=2E.. Add other impossible combinations as you want.

There are reasons fd passing is hard to implement. I find stuffing this
functionality in AF_UNIX was a bad design choice from the very
beginning.

Instead of pushing extra complexity to a single kernel component, why
not trying to use a combination of existing, well designed and supporte=
d
ones ?
