From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] blutetooth: Remove bogus inline for l2cap_chan_connect()
Date: Sun, 15 Jan 2012 12:52:03 +0200
Message-ID: <20120115105203.GA12584@x220.P-661HNU-F1>
References: <1326622076-957-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1326622076-957-1-git-send-email-geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Geert,

On Sun, Jan 15, 2012, Geert Uytterhoeven wrote:
> commit 03a001948166d966d0d580cddb8ae3a23f8b795b ("Bluetooth: invert l=
ocking
> order in connect path") marked l2cap_chan_connect() inline for both t=
he
> prototype in include/net/bluetooth/l2cap.h and the implementation in
> net/bluetooth/l2cap_core.c.
>=20
> As the former doesn't contain an implementation, net/bluetooth/l2cap_=
sock.c
> now fails to build, e.g. for m68k allmodconfig:
>=20
>     net/bluetooth/l2cap_sock.c: In function =E2=80=98l2cap_sock_conne=
ct=E2=80=99:
>     include/net/bluetooth/l2cap.h:838: sorry, unimplemented: inlining=
 failed in call to =E2=80=98l2cap_chan_connect=E2=80=99: function body =
not available
>     net/bluetooth/l2cap_sock.c:126: sorry, unimplemented: called from=
 here
>     make[1]: *** [net/bluetooth/l2cap_sock.o] Error 1
>=20
> As l2cap_chan_connect() is not that small and also called from
> net/bluetooth/l2cap_sock.c, I removed both inline keywords.
>=20
> Signed-off-by: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
> --
> As I can't seem to find anyone else getting this, I guess it's only
> triggered by some versions of gcc. Mine is
>=20
> gcc version 4.1.2 20061115 (prerelease) (Ubuntu 4.1.1-21)
> ---
>  include/net/bluetooth/l2cap.h |    2 +-
>  net/bluetooth/l2cap_core.c    |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)

This was already reported[1] earlier this month and a patch[2] was also
created for it which right now resides in my bluetooth-next tree[3].

Johan

[1] http://www.spinics.net/lists/linux-bluetooth/msg19851.html
[2] http://www.spinics.net/lists/linux-bluetooth/msg20009.html
[3] http://git.kernel.org/?p=3Dlinux/kernel/git/jh/bluetooth-next.git;a=
=3Dcommitdiff;h=3Dcd555072d0b0738c8a107776fe91902da686f94d
