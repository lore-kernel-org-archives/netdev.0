From: Ingo Molnar <mingo@elte.hu>
Subject: [v3.3-rc1 regression] TCP: too many of orphaned sockets
Date: Fri, 27 Jan 2012 13:46:41 +0100
Message-ID: <20120127124641.GA30819@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There's a new TCP regression in latest -git that triggers in=20
randconfig testing.

With the attached config i'm getting tons of these messages:

[   32.751209] TCP: too many of orphaned sockets                       =
                           =20
[   37.198307] TCP: too many of orphaned sockets                       =
                           =20
[   42.464404] TCP: too many of orphaned sockets                       =
                           =20
[   48.920392] TCP: too many of orphaned sockets                       =
                           =20
[   56.370026] TCP: too many of orphaned sockets                       =
                           =20
[   64.605937] TCP: too many of orphaned sockets                    =20

and it's not possible to ssh into the testbox, the TCP=20
connection hangs.

Before i put more effort into debugging this, is this bug=20
already known/fixed?

NOTE: the .config is randconfig generated so it might have a few=20
weird combinations of config options. One such thing i noticed=20
is !CONFIG_BUG, this produces at least one of the following=20
build warnings in the networking code:

net/core/ethtool.c:211:1: warning: control reaches end of non-void func=
tion [-Wreturn-type]
net/core/dev.c:1892:33: warning: unused variable =E2=80=98null_features=
=E2=80=99 [-Wunused-variable]
net/packet/af_packet.c:1878:30: warning: =E2=80=98hdrlen=E2=80=99 may b=
e used uninitialized in this function [-Wmaybe-uninitialized]
net/xfrm/xfrm_policy.c:2456:17: warning: =E2=80=98xfrm_dst_ops=E2=80=99=
 may be used uninitialized in this function [-Wmaybe-uninitialized]
net/xfrm/xfrm_policy.c:1351:7: warning: =E2=80=98dst_ops=E2=80=99 may b=
e used uninitialized in this function [-Wmaybe-uninitialized]
net/xfrm/xfrm_policy.c:1333:18: note: =E2=80=98dst_ops=E2=80=99 was dec=
lared here
net/xfrm/xfrm_policy.c:1351:7: warning: =E2=80=98dst_ops=E2=80=99 may b=
e used uninitialized in this function [-Wmaybe-uninitialized]
net/xfrm/xfrm_policy.c:1333:18: note: =E2=80=98dst_ops=E2=80=99 was dec=
lared here

Note#2, the message should probably be fixed as well:

 -   TCP: too many of orphaned sockets                    =20
 +   TCP: too many orphaned sockets                    =20

Thanks,

	Ingo
