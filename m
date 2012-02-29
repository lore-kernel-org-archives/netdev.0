From: Andrei Emeltchenko <andrei.emeltchenko.news@gmail.com>
Subject: Re: [PATCH] Bluetooth: Silence static checker warning.
Date: Wed, 29 Feb 2012 22:45:49 +0200
Message-ID: <CAMXE1-oXtheVHDuU3w52mXqmuY8AK4kk+tuvJpVRDq2=+qEnsQ@mail.gmail.com>
References: <1330535217-26785-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcel@holtmann.org, padovan@profusion.mobi, davem@davemloft.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: santosh nayak <santoshprasadnayak@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330535217-26785-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Santosh,

On Wed, Feb 29, 2012 at 7:06 PM, santosh nayak
<santoshprasadnayak@gmail.com> wrote:
> From: Santosh Nayak <santoshprasadnayak@gmail.com>
>
> Silencing Static checker warning.
> 1. Endian warning
> 2. variable dereferenced before check 'sk' .
>
> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
> ---
> =A0net/bluetooth/l2cap_sock.c | =A0 =A09 ++++++---
> =A01 files changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
> index 401d942..d206321 100644
> --- a/net/bluetooth/l2cap_sock.c
> +++ b/net/bluetooth/l2cap_sock.c
> @@ -82,7 +82,7 @@ static int l2cap_sock_bind(struct socket *sock, str=
uct sockaddr *addr, int alen)
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (la.l2_cid)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D l2cap_add_scid(chan, la.l2_cid)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D l2cap_add_scid(chan, __le16_to_=
cpu(la.l2_cid));
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D l2cap_add_psm(chan, &la.l2_bda=
ddr, la.l2_psm);
>
> @@ -123,7 +123,8 @@ static int l2cap_sock_connect(struct socket *sock=
, struct sockaddr *addr, int al
> =A0 =A0 =A0 =A0if (la.l2_cid && la.l2_psm)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>
> - =A0 =A0 =A0 err =3D l2cap_chan_connect(chan, la.l2_psm, la.l2_cid, =
&la.l2_bdaddr);
> + =A0 =A0 =A0 err =3D l2cap_chan_connect(chan, la.l2_psm, __le16_to_c=
pu(la.l2_cid),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &la.l2_=
bdaddr);
> =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto done;
>
> @@ -795,7 +796,7 @@ static void l2cap_sock_kill(struct sock *sk)
> =A0static int l2cap_sock_shutdown(struct socket *sock, int how)
> =A0{
> =A0 =A0 =A0 =A0struct sock *sk =3D sock->sk;
> - =A0 =A0 =A0 struct l2cap_chan *chan =3D l2cap_pi(sk)->chan;
> + =A0 =A0 =A0 struct l2cap_chan *chan;
> =A0 =A0 =A0 =A0int err =3D 0;
>
> =A0 =A0 =A0 =A0BT_DBG("sock %p, sk %p", sock, sk);
> @@ -803,6 +804,8 @@ static int l2cap_sock_shutdown(struct socket *soc=
k, int how)
> =A0 =A0 =A0 =A0if (!sk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> + =A0 =A0 =A0 chan =3D l2cap_pi(sk)->chan;
> +

Didn't I fix this bug already?

http://permalink.gmane.org/gmane.linux.bluez.kernel/21537

Regards,
Andrei
