From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: Re: [PATCH 1/2] net: Fix the condition passed to sk_wait_event()
Date: Sat, 2 Oct 2010 18:30:04 -0700 (PDT)
Message-ID: <326156.76745.qm@web53706.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,
     Thinking more about it, we need to check for sk->sk_err, thus the=20
existing code behaves fine. Just that we might incur an additional slee=
p
even while we know that the socket already has an error, but that shoul=
d
be ok.
We only need the other patch. Pls ignore this, and sorry for the confus=
ion.

Thanks,
Tomar

--- On Sun, 3/10/10, Nagendra Tomar <tomer_iisc@yahoo.com> wrote:

> From: Nagendra Tomar <tomer_iisc@yahoo.com>
> Subject: [PATCH 1/2] net: Fix the condition passed to sk_wait_event()
> To: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org, davem@davemloft.net
> Date: Sunday, 3 October, 2010, 5:19
> This patch fixes the sk_wait_event()
> condition in the sk_stream_wait_connect()=20
> function. With this change, we correctly check for the
> TCPF_ESTABLISHED and=20
> TCPF_CLOSE_WAIT states and avoid potentially returning
> success when there
> might be an error on the socket.
>=20
> Signed-off-by: Nagendra Singh Tomar
> <tomer_iisc@xxxxxxxxx>
> ---
> --- linux-2.6.35.7/net/core/stream.c.orig=A0=A0=A0
> 2010-03-24 09:30:00.000000000 +0530
> +++ linux-2.6.35.7/net/core/stream.c=A0=A0=A0
> 2010-03-24 09:30:17.000000000 +0530
> @@ -73,9 +73,8 @@ int sk_stream_wait_connect(struct sock *
>  =A0=A0=A0 =A0=A0=A0
> prepare_to_wait(sk_sleep(sk), &wait,
> TASK_INTERRUPTIBLE);
>  =A0=A0=A0 =A0=A0=A0
> sk->sk_write_pending++;
>  =A0=A0=A0 =A0=A0=A0 done =3D
> sk_wait_event(sk, timeo_p,
> -=A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> =A0=A0=A0 =A0 =A0=A0=A0!sk->sk_err
> &&
> -=A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> =A0=A0=A0 =A0 =A0=A0=A0!((1 <<
> sk->sk_state) &
> -=A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> =A0=A0=A0 =A0 =A0
> =A0=A0=A0~(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)));
> +=A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> =A0=A0=A0 =A0 =A0=A0=A0((1 <<
> sk->sk_state) &
> +=A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> =A0=A0=A0 =A0 =A0
> =A0=A0=A0(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)));
>  =A0=A0=A0 =A0=A0=A0
> finish_wait(sk_sleep(sk), &wait);
>  =A0=A0=A0 =A0=A0=A0
> sk->sk_write_pending--;
>  =A0=A0=A0 } while (!done);
>=20
> ---
>=20
>=20
>=20
>=20
>=20



     =20
