From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Sun, 18 Jul 2010 10:33:10 +0200
Message-ID: <1279441990.2476.26.camel@edumazet-laptop>
References: <201007170114.GFC57373.SQJHOVtLFMOFFO@I-love.SAKURA.ne.jp>
	 <20100716.123558.71592004.davem@davemloft.net>
	 <201007171017.DFC73498.SFFFOMLVJOHOtQ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	paul.moore@hp.com, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201007171017.DFC73498.SFFFOMLVJOHOtQ@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 17 juillet 2010 =C3=A0 10:17 +0900, Tetsuo Handa a =C3=A9crit=
 :
> David Miller wrote:
> > From: Tetsuo Handa
> > Date: Sat, 17 Jul 2010 01:14:38 +0900
> >=20
> > > Below is a patch for post recvmsg() operation. I modified the pat=
ch to call
> > > skb_recv_datagram() again (for udp_recvmsg(), raw_recvmsg(), udpv=
6_recvmsg())
> > > if LSM dicided to drop the message. (Regarding rawv6_recvmsg(), I=
 didn't do so
> > > in accordance with the comment at "csum_copy_err:".)
> > > What do you think about this verion?
> >=20
> > This looks fine, but regardless of that comment I think the IPV6 ra=
w recvmsg()
> > should loop just as the IPV4 one does in your patch.
> >=20
> Thank you, David.
> I updated to call skb_recv_datagram() for rawv6_recvmsg() case too.
>=20
> NETWORKING [IPv4/IPv6] maintainers and Paul, is below patch fine for =
you?
>=20
> Regards.
> ----------------------------------------
> >From b43154a90bc7494ec1ee301e692d2bbf29c8f2f8 Mon Sep 17 00:00:00 20=
01
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 17 Jul 2010 09:52:38 +0900
> Subject: [PATCH] LSM: Add post recvmsg() hook.
>=20
> Current pre recvmsg hook (i.e. security_socket_recvmsg()) has two pro=
blems.
>=20
> One is that it will cause eating 100% of CPU time if the caller does =
not
> close() the socket when recvmsg() failed due to security_socket_recvm=
sg(), for
> subsequent select() notifies the caller of readiness for recvmsg() si=
nce the
> datagram which would have been already picked up if security_socket_r=
ecvmsg()
> did not return error is remaining in the queue.
>=20
> The other is that it is racy if LSM module wants to do filtering base=
d on
> "which process can pick up datagrams from which source" because the p=
rocess
> which picks up the datagram is not known until skb_recv_datagram() an=
d lock
> is not held between security_socket_recvmsg() and skb_recv_datagram()=
=2E
>=20
> This patch introduces post recvmsg hook (i.e. security_socket_post_re=
cvmsg())
> in order to solve above problems at the cost of ability to pick up th=
e datagram
> which would have been picked up if preceding security_socket_post_rec=
vmsg() did
> not return error.
>=20
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

I read this patch and could not find out if an SNMP counter was
increased in the case a frame was not delivered but dropped in kernel
land.



--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
