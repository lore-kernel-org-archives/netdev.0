From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: r8169 transmit queue time outs
Date: Wed, 19 May 2010 16:18:27 +0200
Message-ID: <1274278707.2766.116.camel@edumazet-laptop>
References: <20100506141715.GC4480@ihatethathostname.lab.bos.redhat.com>
	 <20100506201024.GA3541@electric-eye.fr.zoreil.com>
	 <20100519134344.GI3900@ihatethathostname.lab.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	dgilmore@redhat.com
To: Kyle McMartin <kmcmartin@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46401 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175Ab0ESOSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 10:18:33 -0400
Received: by fxm10 with SMTP id 10so2394701fxm.19
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 07:18:31 -0700 (PDT)
In-Reply-To: <20100519134344.GI3900@ihatethathostname.lab.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 mai 2010 =C3=A0 09:43 -0400, Kyle McMartin a =C3=A9crit =
:
> On Thu, May 06, 2010 at 10:10:24PM +0200, Francois Romieu wrote:
> > Kyle McMartin <kmcmartin@redhat.com> :
> > [...]
> > > Some of our users have been seeing their r8169 cards just up and =
stop
> > > transmitting packets pretty quickly after boot with recent kernel=
s.
> > [...]
> > > Pid: 0, comm: swapper Not tainted 2.6.31.5-127.fc12.i686.PAE #1
> >=20
> > Can they upgrade to 2.6.32.11-99.fc12.i686 and try an out-of-tree b=
uild
> > of the driver at http://userweb.kernel.org/~romieu/r8169/2.6.32.11-=
99.fc12/ ?
> >=20
> > It should be quite close to the current git kernel.
> >=20
>=20
> I provided a bunch of testers with a backport of the current git head
> r8169 driver, and sadly, they report the TX timeout issues still occu=
r.
> :/
>=20
> Any other ideas?

Scratch the NIC ?

Normally not related, but I mentioned once following patch that could b=
e
tried. (Not reset the NIC if we receive too many frames in a row)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 217e709..c4dbb15 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4520,10 +4520,8 @@ static int rtl8169_rx_interrupt(struct net_devic=
e *dev,
 				dev->stats.rx_length_errors++;
 			if (status & RxCRC)
 				dev->stats.rx_crc_errors++;
-			if (status & RxFOVF) {
-				rtl8169_schedule_work(dev, rtl8169_reset_task);
+			if (status & RxFOVF)
 				dev->stats.rx_fifo_errors++;
-			}
 			rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 		} else {
 			struct sk_buff *skb =3D tp->Rx_skbuff[entry];


