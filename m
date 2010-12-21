From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] TCP: increase default initial receive window.
Date: Tue, 21 Dec 2010 19:49:07 +0100
Message-ID: <1292957347.2720.45.camel@edumazet-laptop>
References: <1292642451-892-1-git-send-email-nanditad@google.com>
	 <AANLkTikcS-U9yA05dTp_y4EciwtUsjSonjc+bkA=57=4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nandita Dukkipati <nanditad@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49219 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136Ab0LUStN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 13:49:13 -0500
Received: by wwa36 with SMTP id 36so4458722wwa.1
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 10:49:12 -0800 (PST)
In-Reply-To: <AANLkTikcS-U9yA05dTp_y4EciwtUsjSonjc+bkA=57=4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 d=C3=A9cembre 2010 =C3=A0 13:27 -0500, John Heffner a =C3=A9=
crit :
> I know this has already been applied, but one thing to think about:
> Linux announces a small initial window to prevent overflowing the
> receive buffer when receiving segments smaller than the link MTU.

Overflowing receive buffer ? Which one ? Do you mean NIC RX ring
buffer ?

> Increasing this even to 10 segments might have some negative
> consequences.  I recall, for instance, some drivers when configured
> with a 9000 byte MTU, have a single pool of receive buffers all 16k
> (the next highest power of 2).  So each received segment will get 16k
> of allocated memory accounted to it, even if the incoming segments ar=
e
> <=3D1460 bytes long.  The default initial rcvbuf of 87380 bytes is le=
ss
> than the 160k of memory that the initial window might consume, so
> we're going to start hitting the very slow path of coalescing segment=
s
> to get back under memory bounds.

Patch is not allowing 87380 bytes, but 10 segments, limited to 14600
bytes. Its very conservative IMHO.

>=20
> Some drivers are smarter about having multiple pools of receive
> buffers with different sizes, so it might not be so easy to hit this
> condition.  I haven't looked at any of them for a while.  Is this
> still a real concern?

I dont think so. You would have problem anyway, since the patch changes
only _initial_ receive window. After some kbytes of data exchanged,
window is probably larger.


