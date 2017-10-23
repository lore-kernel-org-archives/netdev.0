From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Subject: Re: [PATCH v2] net/sock: Update sk rcu iterator macro.
Date: Mon, 23 Oct 2017 18:42:50 +0000
Message-ID: <20171023184247.p54glyvdkgaxht2f@sasha-lappy>
References: <20171023153922.orgvwmuvokv6xbi4@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Tim Hansen <devtimhansen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171023153922.orgvwmuvokv6xbi4@debian>
Content-Language: en-US
Content-ID: <883DF4C80EEA00428803DCF4B6E2F5B2@vzwcorp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 23, 2017 at 11:39:22AM -0400, Tim Hansen wrote:
>Mark hlist nodes in sk rcu iterator as protected by the rcu.
>hlist_next_rcu accomplishes this and silences the warnings
>sparse throws for net/ipv4/udp.c and net/ipv6/udp.c.
>
>Found with make C=3D1 net/ipv4/udp.o on linux-next tag
>next-20171009.
>
>Signed-off-by: Tim Hansen <devtimhansen@gmail.com>
>---
> include/net/sock.h | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/include/net/sock.h b/include/net/sock.h
>index 64e5ac41b9cf..96cb7b7e4924 100644
>--- a/include/net/sock.h
>+++ b/include/net/sock.h
>@@ -737,10 +737,10 @@ static inline void sk_add_bind_node(struct sock *sk,
>  *
>  */
> #define sk_for_each_entry_offset_rcu(tpos, pos, head, offset)		       \
>-	for (pos =3D rcu_dereference((head)->first);			       \
>+	for (pos =3D rcu_dereference(hlist_next_rcu((head)->first));	       \

See below.

> 	     pos !=3D NULL &&						       \
> 		({ tpos =3D (typeof(*tpos) *)((void *)pos - offset); 1;});       \
>-	     pos =3D rcu_dereference(pos->next))
>+	     pos =3D rcu_dereference(hlist_next_rcu(pos->next)))

This will return the next-next node instead of just the next one. You
probably want just hlist_next_rcu(pos) here.

--=20

Thanks,
Sasha=
