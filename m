From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [RFC PATCH] network: return errors if we know tcp_connect
 failed
Date: Fri, 12 Nov 2010 17:15:32 +0100
Message-ID: <1289578532.3185.265.camel@edumazet-laptop>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com>
	 <00c201cb81eb$84e18160$8ea48420$@com>
	 <1289578108.3083.95.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hua Zhong <hzhong@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1289578108.3083.95.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 12 novembre 2010 =C3=A0 11:08 -0500, Eric Paris a =C3=A9cri=
t :

> 2) What should the generic TCP code (tcp_connect()) do if the skb fai=
led
> to send.  Should it return error codes back up the stack somehow or
> should they continue to be ignored?  Obviously continuing to just ign=
ore
> information we have doesn't make me happy (otherwise I wouldn't have
> started scratching this itch).  But the point about ENOBUFS is well
> taken.  Maybe I should make tcp_connect(), or the caller to
> tcp_connect() more intelligent about specific error codes?
>=20
> I'm looking for a path forward.  If SELinux is rejecting the SYN pack=
ets
> on connect() I want to pass that info to userspace rather than just
> hanging.  What's the best way to accomplish that?
>=20

Eric, if you can differentiate a permanent reject, instead of a
temporary one (congestion, or rate limiting, or ENOBUF, or ...), then
yes, you could make tcp_connect() report to user the permanent error,
and ignore the temporary one.
