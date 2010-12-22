From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Help: major pppoe regression since 2.6.35 (panic on first ppp
 conection)?
Date: Wed, 22 Dec 2010 17:25:00 +0100
Message-ID: <1293035100.3027.247.camel@edumazet-laptop>
References: <20101222110021.GA8985@ff.dom.local>
	 <4D122093.6060900@scarlet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Joel Soete <soete.joel@scarlet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D122093.6060900@scarlet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 17:00 +0100, Joel Soete a =C3=A9=
crit :
> Hello Jarek,
>=20
> Nice to read you :<)
>=20
> On 12/22/2010 12:00 PM, Jarek Poplawski wrote:
> > On 2010-12-22 09:22, Andrew Morton wrote:
> >> (cc netdev)
> >>
> >> The bug is still present in 2.6.37-rc6.
> >>
> >> On Sat, 18 Dec 2010 11:33:14 +0000 Joel Soete<soete.joel@scarlet.b=
e>  wrote:
> >>
> >>> Hello all,
> >
> > Hi,
> > Could you reproduce this bug with a vanilla kernel (without nvidia
> > patch)? If so, please include dmesg and .config to the next report.
> >
> Yes (it was already a vanilla kernel but 2.6.35 with my config, even =
thought same issue occurs some other distro stock=20
> kernel 2.6.35), but here are some more dmesg with vanilla 2.6.37-rc6 =
and rc7 (I just added your debugging patch
> I found here, just because if I don't do it kernel is panicing immedi=
ately without letting any chance to capture dmesg (and=20
> unfortunately I don't have any more chance to grab panic messages fro=
m serial console: no more rs232 on latest office laptop :<)
>=20
> So you will find here attached personal config files of 2 kernels and=
 respective dmesg.
>=20
> If ever you need more details, don't hesitate to ask me.
>=20
> Thanks a lot,
> 	J.

Something overwrites nr_frags in skb_shinfo(skb)

As skb_shinfo follows head portion of an skb, something overflows skb
head

Please try adding some room like in following patch ?

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e6ba898..adf2834 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -187,6 +187,7 @@ enum {
  * the end of the header data, ie. at skb->end.
  */
 struct skb_shared_info {
+	char		filler[64];
 	unsigned short	nr_frags;
 	unsigned short	gso_size;
 	/* Warning: this field is not always filled in (UFO)! */
