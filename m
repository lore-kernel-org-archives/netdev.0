From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Wed, 01 Sep 2010 17:54:23 +0200
Message-ID: <1283356463.2556.351.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1008222233530.31382@pokey.mtv.corp.google.com>
	 <20100823105933.27cd0b80@nehalam>
	 <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41143 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742Ab0IAPy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 11:54:29 -0400
Received: by wwj40 with SMTP id 40so135719wwj.1
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 08:54:28 -0700 (PDT)
In-Reply-To: <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 septembre 2010 =C3=A0 08:41 -0700, Tom Herbert a =C3=A9c=
rit :
> > Why don't we do this in the normal transmit processing.
> > There is already so much policy mechanism filters/actions/qdisc tha=
t
> > doing it in higher level is fighting against these.
> >
> Are you proposing that TX queue selection be done in the qdiscs?  The
> queue has to be selected before taking the lock (cannot afford taking
> a lock over the whole interface).  This would necessitate moving the
> locking and probably rearranging a lot of the xmit code around that.

Stephen point is not adding yet another layer 'before' qdisc layer.

I would like something not as complex as your patch.

1) Why current selection fails ?

2) Could we change current selection to :

 - Use a lightweight selection, with no special configuration.

 - Use driver RX multiqueue information if available, in a one-to-one
relationship.

3) Eventually have a user selectable selection (socket option, or syste=
m
wide, but one sysctl, not many bitmasks ;) ).



