From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Tue, 10 Nov 2009 11:55:59 +0100
Message-ID: <4AF946BF.30800@gmail.com>
References: <4AF924A5.1050303@gmail.com> <4AF9406C.8010603@trash.net> <412e6f7f0911100248mbc14287p26c43141d6ab202c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35215 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222AbZKJK4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 05:56:01 -0500
In-Reply-To: <412e6f7f0911100248mbc14287p26c43141d6ab202c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =C3=A9crit :
> On Tue, Nov 10, 2009 at 6:29 PM, Patrick McHardy <kaber@trash.net> wr=
ote:
>> I'm not sure how this will help, ifb device transmission is
>> still serialized by the ingress queue lock and the mirred lock.
>>
>=20
> But not in ifb_thread. For firewall the main routine is after
> netif_rx_ni(). For server applications, the packets belong to the sam=
e
> flow are always routed to the same CPU, and the applications can
> benefit with better localization.
>=20

Hmm, you know many cache lines already were bringed into cpu receiving
the original softirq ? But yes, this is a possible way to go / try :)

Please submit your future patch on top of net-next-2.6, because
I see you still use dev_get_by_index() :-(

commit 05e8689c9a3a208bf75b60662778d81e23eac460
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Sun Nov 1 19:45:16 2009 +0000

    ifb: RCU locking avoids touching dev refcount
   =20
    Avoids touching dev refcount in hotpath
   =20
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit db519144243de6b17ff0c56c26f06059743110a7
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Tue Oct 20 02:35:50 2009 +0000

    ifb: should not use __dev_get_by_index() without locks
   =20
    At this point (ri_tasklet()), RTNL or dev_base_lock are not held,
    we must use dev_get_by_index() instead of __dev_get_by_index()
   =20
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


