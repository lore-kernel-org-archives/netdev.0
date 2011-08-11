From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] tcp: Replace possible syn attack msg by counters
Date: Thu, 11 Aug 2011 08:33:07 +0200
Message-ID: <1313044387.3066.8.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1108102229130.5341@pokey.mtv.corp.google.com>
	 <20110810.231318.959972077845910551.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51939 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116Ab1HKGdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 02:33:14 -0400
Received: by wwf5 with SMTP id 5so1716906wwf.1
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2011 23:33:13 -0700 (PDT)
In-Reply-To: <20110810.231318.959972077845910551.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 ao=C3=BBt 2011 =C3=A0 23:13 -0700, David Miller a =C3=A9=
crit :
> From: Tom Herbert <therbert@google.com>
> Date: Wed, 10 Aug 2011 22:38:02 -0700 (PDT)
>=20
> > Rather than printing the message to the log, use a mib counter to k=
eep
> > track of the count of occurences of syn cookies being used or syn
> > being dropped when request queue is full.
> >=20
> > Rationale is these messages can fill up /var/log/messages on server
> > which is simply under heavy load... I'm not sure how much more usef=
ul
> > they would be in identifying a server DOS attack (compared to
> > counters).
> >=20
> > Signed-off-by: Tom Herbert <therbert@google.com>
>=20
> Print the message once, and also do the counters.
>=20
> Say something like "Possible SYN flooding, see SNMP counters." or
> similar.
>=20
> Because if people are grepping for that message in their logs, they
> will now have a false sense of confidence seeing it not being there
> any more.

An alternative would be to guard the message by net_msg_warn
(/proc/sys/net/core/warnings)

LIMIT_NETDEBUG(KERN_INFO "TCP: Possible SYN flooding on port %d. %s.\n"=
=20
	...)



