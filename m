From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] bql: Byte queue limits
Date: Tue, 26 Apr 2011 18:37:35 +0200
Message-ID: <1303835855.3358.64.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1104252128290.5895@pokey.mtv.corp.google.com>
	 <20110426091620.7c576a98@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35385 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752188Ab1DZQhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 12:37:39 -0400
Received: by wya21 with SMTP id 21so609550wya.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 09:37:38 -0700 (PDT)
In-Reply-To: <20110426091620.7c576a98@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 avril 2011 =C3=A0 09:16 -0700, Stephen Hemminger a =C3=A9cr=
it :

> Although this is implemented as a device attribute, from a layering
> point of view it feels like a queuing strategy. Having two competing
> ways to do something is not always a good idea. Why is this not a
> qdisc parameter or a new qdisc?
>=20

The dequeue thing is performed in TX completion (one call for all
dequeued skbs to reduce overhead).

But its right the queueing test could be done generically (stop the
queue if limit reached).

BTW I did not check if both paths were SMP safe if run concurrently...


