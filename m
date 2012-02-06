From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v1, kernel version 3.2.1] rtnetlink workaround around
 the skb buff size issue
Date: Mon, 06 Feb 2012 17:56:06 +0100
Message-ID: <1328547366.2220.83.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120203.192933.510206531351047222.davem@davemloft.net>
	 <C5551D9AAB213A418B7FD5E4A6F30A0702F7F86F@ORSMSX106.amr.corp.intel.com>
	 <CAGsizzLFoXdUQrA-WtdRq4FDdnDNnevyK6HCRmrT2joUV=ZRXg@mail.gmail.com>
	 <20120206.101517.1598607878740481170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steweg@ynet.sk, gregory.v.rose@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120206.101517.1598607878740481170.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 06 f=C3=A9vrier 2012 =C3=A0 10:15 -0500, David Miller a =C3=A9=
crit :
> From: =C5=A0tefan Gula <steweg@ynet.sk>
> Date: Mon, 6 Feb 2012 09:53:28 +0100
>=20
> > If I try to request for it, it will eventually fail with a lot of
> > records even with filtering...
>=20
> Then the user can loop increasing the buffer size until the netlink
> request succeeds.
>=20
> It is not a problem.

Actually we always truncate message in netlink_recvmsg()

We could use a MSG_NOPARTIAL flag in netlink_recvmsg() so that user can
avoid the MSG_PEEK operation to fetch next message length.

(Ie not consume/copy skb if user buffer is too small to hold full
message, and only return the needed length)
