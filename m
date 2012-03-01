From: santosh prasad nayak <santoshprasadnayak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Bluetooth: Silence static checker warning.
Date: Thu, 1 Mar 2012 11:07:14 +0530
Message-ID: <CAOD=uF5Ux0w=EPbX0V3qOy1VnZQr6Q35uUxrF9Qv1hZ4MjYJOA@mail.gmail.com>
References: <1330535217-26785-1-git-send-email-santoshprasadnayak@gmail.com>
	<CAMXE1-oXtheVHDuU3w52mXqmuY8AK4kk+tuvJpVRDq2=+qEnsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrei Emeltchenko <andrei.emeltchenko.news-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMXE1-oXtheVHDuU3w52mXqmuY8AK4kk+tuvJpVRDq2=+qEnsQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

@Dan,
           In future patches I will take care of it. Is it ok ? If
required I can resend the patch with required changes on subject line.

@Andrei

In my local clone your changes are  not visible.

What is the schedule of linux-next ?
Is it updated every week or bi-weekly or monthly ?

Regards
Santosh

On Thu, Mar 1, 2012 at 2:15 AM, Andrei Emeltchenko
<andrei.emeltchenko.news-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Hi Santosh,
>
> On Wed, Feb 29, 2012 at 7:06 PM, santosh nayak
> <santoshprasadnayak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> From: Santosh Nayak <santoshprasadnayak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>
>> Silencing Static checker warning.
>> 1. Endian warning
>> 2. variable dereferenced before check 'sk' .
>>
>> Signed-off-by: Santosh Nayak <santoshprasadnayak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>> =A0net/bluetooth/l2cap_sock.c | =A0 =A09 ++++++---
>> =A01 files changed, 6 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
>> index 401d942..d206321 100644
>> --- a/net/bluetooth/l2cap_sock.c
>> +++ b/net/bluetooth/l2cap_sock.c
>> @@ -82,7 +82,7 @@ static int l2cap_sock_bind(struct socket *sock, st=
ruct sockaddr *addr, int alen)
>> =A0 =A0 =A0 =A0}
>>
>> =A0 =A0 =A0 =A0if (la.l2_cid)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D l2cap_add_scid(chan, la.l2_cid=
);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D l2cap_add_scid(chan, __le16_to=
_cpu(la.l2_cid));
>> =A0 =A0 =A0 =A0else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D l2cap_add_psm(chan, &la.l2_bd=
addr, la.l2_psm);
>>
>> @@ -123,7 +123,8 @@ static int l2cap_sock_connect(struct socket *soc=
k, struct sockaddr *addr, int al
>> =A0 =A0 =A0 =A0if (la.l2_cid && la.l2_psm)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>>
>> - =A0 =A0 =A0 err =3D l2cap_chan_connect(chan, la.l2_psm, la.l2_cid,=
 &la.l2_bdaddr);
>> + =A0 =A0 =A0 err =3D l2cap_chan_connect(chan, la.l2_psm, __le16_to_=
cpu(la.l2_cid),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &la.l2=
_bdaddr);
>> =A0 =A0 =A0 =A0if (err)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto done;
>>
>> @@ -795,7 +796,7 @@ static void l2cap_sock_kill(struct sock *sk)
>> =A0static int l2cap_sock_shutdown(struct socket *sock, int how)
>> =A0{
>> =A0 =A0 =A0 =A0struct sock *sk =3D sock->sk;
>> - =A0 =A0 =A0 struct l2cap_chan *chan =3D l2cap_pi(sk)->chan;
>> + =A0 =A0 =A0 struct l2cap_chan *chan;
>> =A0 =A0 =A0 =A0int err =3D 0;
>>
>> =A0 =A0 =A0 =A0BT_DBG("sock %p, sk %p", sock, sk);
>> @@ -803,6 +804,8 @@ static int l2cap_sock_shutdown(struct socket *so=
ck, int how)
>> =A0 =A0 =A0 =A0if (!sk)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>>
>> + =A0 =A0 =A0 chan =3D l2cap_pi(sk)->chan;
>> +
>
> Didn't I fix this bug already?
>
> http://permalink.gmane.org/gmane.linux.bluez.kernel/21537
>
> Regards,
> Andrei
