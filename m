From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: Re: pull request: wireless-next-2.6 2011-05-16-v2
Date: Tue, 17 May 2011 11:13:16 -0300
Message-ID: <20110517141316.GA3138@joana>
References: <20110516211305.GG6551@tuxdriver.com>
 <20110517000809.GA2119@tuxdriver.com>
 <20110516.230835.989629139579226478.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:40897 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754769Ab1EQOMm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 10:12:42 -0400
Content-Disposition: inline
In-Reply-To: <20110516.230835.989629139579226478.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller <davem@davemloft.net> [2011-05-16 23:08:35 -0400]:

> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Mon, 16 May 2011 20:08:09 -0400
>=20
> > I'm sorry, Dave!  In my defense, I am on the verge of sickness and =
got
> > very little sleep last night... :-(
> >=20
> > I have corrected the problem and was sure to perform the correct bu=
ild
> > test this time! :-)
>=20
> So these hunks made to net/bluetooth/l2cap_core.c:
>=20
> @@ -3745,11 +3758,14 @@ done:
>  static inline int l2cap_conless_channel(struct l2cap_conn *conn, __l=
e16 psm, struct sk_buff *skb)
>  {
>  	struct sock *sk;
> +	struct l2cap_chan *chan;
> =20
> -	sk =3D l2cap_get_sock_by_psm(0, psm, conn->src);
> -	if (!sk)
> +	chan =3D l2cap_global_chan_by_psm(0, psm, conn->src);
> +	if (!chan)
>  		goto drop;
> =20
> +	sk =3D chan->sk;
> +
>  	bh_lock_sock(sk);
> =20
>  	BT_DBG("sk %p, len %d", sk, skb->len);
> @@ -3745,11 +3758,14 @@ done:
>  static inline int l2cap_conless_channel(struct l2cap_conn *conn, __l=
e16 psm, struct sk_buff *skb)
>  {
>  	struct sock *sk;
> +	struct l2cap_chan *chan;
> =20
> -	sk =3D l2cap_get_sock_by_psm(0, psm, conn->src);
> -	if (!sk)
> +	chan =3D l2cap_global_chan_by_psm(0, psm, conn->src);
> +	if (!chan)
>  		goto drop;
> =20
> +	sk =3D chan->sk;
> +
>  	bh_lock_sock(sk);
> =20
>  	BT_DBG("sk %p, len %d", sk, skb->len);
>=20
> Doesn't generate the following warnings on your compiler?
>=20
> net/bluetooth/l2cap_core.c: In function =E2=80=98l2cap_recv_frame=E2=80=
=99:
> net/bluetooth/l2cap_core.c:3758:15: warning: =E2=80=98sk=E2=80=99 may=
 be used uninitialized in this function
> net/bluetooth/l2cap_core.c:3758:15: note: =E2=80=98sk=E2=80=99 was de=
clared here
> net/bluetooth/l2cap_core.c:3791:15: warning: =E2=80=98sk=E2=80=99 may=
 be used uninitialized in this function
> net/bluetooth/l2cap_core.c:3791:15: note: =E2=80=98sk=E2=80=99 was de=
clared here
>=20

I keep not seeing these warnings. I'll upgrade to gcc 4.6 and check thi=
s again.

padovan bluetooth-next-2.6 $ rm net/bluetooth/*.o net/bluetooth/*.ko
padovan bluetooth-next-2.6 $ make
  CHK     include/linux/version.h
  CHK     include/generated/utsrelease.h
  UPD     include/generated/utsrelease.h
  CALL    scripts/checksyscalls.sh                                     =
                            =20
  CHK     include/generated/compile.h                                  =
                            =20
  UPD     include/generated/compile.h                                  =
                            =20
  CC      init/version.o                                               =
                            =20
  CC      kernel/module.o                                              =
                            =20
  LD      init/built-in.o                                              =
                            =20
  CC      kernel/kexec.o                                               =
                            =20
  LD      kernel/built-in.o                                            =
                            =20
  LD      net/bluetooth/built-in.o                                     =
                            =20
  CC [M]  net/bluetooth/af_bluetooth.o                                 =
                            =20
  CC [M]  net/bluetooth/hci_core.o                                     =
                            =20
  CC [M]  net/bluetooth/hci_conn.o                                     =
                            =20
  CC [M]  net/bluetooth/hci_event.o                                    =
                            =20
  CC [M]  net/bluetooth/mgmt.o                                         =
                            =20
  CC [M]  net/bluetooth/hci_sock.o                                     =
                            =20
  CC [M]  net/bluetooth/hci_sysfs.o                                    =
                            =20
  CC [M]  net/bluetooth/lib.o                                          =
                            =20
  CC [M]  net/bluetooth/l2cap_core.o                                   =
                            =20
  CC [M]  net/bluetooth/l2cap_sock.o                                   =
                            =20
  CC [M]  net/bluetooth/sco.o                                          =
                            =20
  LD [M]  net/bluetooth/bluetooth.o                                    =
                            =20
  LD      vmlinux.o  =20

--=20
Gustavo F. Padovan
http://profusion.mobi
