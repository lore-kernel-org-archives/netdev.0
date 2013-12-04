From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: 2e685cad5790 build warning
Date: Wed, 4 Dec 2013 17:47:15 -0500
Message-ID: <20131204224715.GD21724@cmpxchg.org>
References: <20131204222943.GC21724@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Glauber Costa <glommer@gmail.com>, netdev@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20131204222943.GC21724@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

[ botched linux-kernel address in the first try ]

On Wed, Dec 04, 2013 at 05:29:43PM -0500, Johannes Weiner wrote:
> Hi Eric,
>=20
> commit 2e685cad57906e19add7189b5ff49dfb6aaa21d3
> Author: Eric W. Biederman <ebiederm@xmission.com>
> Date:   Sat Oct 19 16:26:19 2013 -0700
>=20
>     tcp_memcontrol: Kill struct tcp_memcontrol
>    =20
>     Replace the pointers in struct cg_proto with actual data fields and=
 kill
>     struct tcp_memcontrol as it is not fully redundant.
>    =20
>     This removes a confusing, unnecessary layer of abstraction.
>    =20
>     Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> triggers a build warning because it removed the only reference to a
> function but not the function itself:
>=20
> linux/net/ipv4/tcp_memcontrol.c:9:13: warning: =E2=80=98memcg_tcp_enter=
_memory_pressure=E2=80=99 defined but not used [-Wunused-function]
>  static void memcg_tcp_enter_memory_pressure(struct sock *sk)
>=20
> I can not see from the changelog why this function is no longer used,
> or who is supposed to now set cg_proto->memory_pressure which you
> still initialize etc.  Either way, the current state does not seem to
> make much sense.  The author would be the best person to double check
> such changes, but he wasn't copied on your patch, so I copied him now.
>=20
> Apologies if this has been brought up before, I could not find any
> reference on LKML of either this patch or a report of this warning.
>=20
> Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
