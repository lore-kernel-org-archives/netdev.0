From: =?UTF-8?B?Q2h1bmctWWloIFdhbmcgKOeOi+W0h+aHvyk=?=
	<cywang@google.com>
Subject: Re: [PATCH] net: Fix sk_dst_check() to reset the obsolete dst_entry
 of a socket.
Date: Sat, 9 Oct 2010 18:10:01 -0700
Message-ID: <AANLkTikemrEFhgWNSf0wzW2C-yeC3_0qLrE6sW8wqyja@mail.gmail.com>
References: <AANLkTikkv4htP1f=KFwSaa8=K6LicDN0eusXctow-Efb@mail.gmail.com>
 <20101006.003541.71128466.davem@davemloft.net> <AANLkTikx+GadeYfg5rZNxsEig-0Af97ER7V94fjaVc+U@mail.gmail.com>
 <AANLkTimF7piLEy7BUP4-BnmiiGT4NimZw0gE+kmYQd-c@mail.gmail.com> <AANLkTikz8=H9=O2RR9J0=rHm7pcwabnMupKfiSfGnt1k@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	timo.teras@iki.fi
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikz8=H9=O2RR9J0=rHm7pcwabnMupKfiSfGnt1k@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After I gave it a try, that patch worked. Please ignore my patch then. =
Thanks!

On Thu, Oct 7, 2010 at 12:37 PM, Chung-Yih Wang (=E7=8E=8B=E5=B4=87=E6=87=
=BF) <cywang@google.com> wrote:
> As I am testing the l2tp/ipsec client(it is working fine on 2.6.32 bu=
t
> failed on 2.6.35 with the same client). Please see the following log
> dump for sk_dst_check().
>
> <2>[ =C2=A0201.390289] =3D=3D=3D=3D sk_dst_check sk=3DC7485800 dst=3D=
C717AC60
> obsolete=3DFFFFFFFF cookie=3D0 check=3DC0296510
> <2>[ =C2=A0211.247467] =3D=3D=3D=3D sk_dst_check sk=3DC7485000 dst=3D=
C717AC60
> obsolete=3DFFFFFFFF cookie=3D0 check=3DC0296510
>
> [Basically, the ipsec tunnel is built and then free the dst_entry for
> this l2tp socket. Therefore, the obsolete entry should be reset in
> sk_dst_check(). However, the kernel 2.6.35 will do nothing here since
> the ipv4_dst_check still return the obsolete entry even if it is
> obsolete(dst->obsolete=3D2)]
>
> <2>[ =C2=A0216.571350] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <6>[ =C2=A0218.069396] alg: No test for authenc(hmac(sha1),cbc(des3_e=
de))
> (authenc(hmac(sha1-generic),cbc(des3_ede-generic)))
> <6>[ =C2=A0218.164764] batt: =C2=A096%, 4114 mV, 0 mA (-6 avg), 27.2 =
C, 1305 mAh
> <2>[ =C2=A0218.575561] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0220.580535] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0222.585754] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0224.591522] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0226.599212] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0228.602600] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0230.608062] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0232.613464] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0234.618896] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0236.623504] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0238.628936] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0240.634338] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0242.639709] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0244.645111] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0246.648864] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0248.654693] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0250.660125] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
> <2>[ =C2=A0252.665527] =3D=3D=3D=3D sk_dst_check sk=3DC7485400 dst=3D=
C6F670E0
> obsolete=3D00000002 cookie=3D0 check=3DC0296510
>
