From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v2, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Tue, 17 Jan 2012 12:15:51 +0100
Message-ID: <1326798951.2259.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAGsizz+x1GVNR9Pz=b7wO0ELx29=FMosfvhQWL5K26EpkwsUCg@mail.gmail.com>
	 <1326745733.2564.14.camel@edumazet-laptop>
	 <CAGsizz+2nH+Sx+7TjZwEeKBiHbio0BxoN7CgT4Sspp0EzRN6Ug@mail.gmail.com>
	 <1326775643.2564.36.camel@edumazet-laptop>
	 <CAGsizz+kgBB9APmU9dPExkGQvPUVa3m6qz3NvSguPYNuJQQ_7Q@mail.gmail.com>
	 <1326788970.2564.52.camel@edumazet-laptop>
	 <CAGsizzLwCTpuZsZyx24T9WZy1DSJo+rfhDxLsE8UmeZOSxw+mA@mail.gmail.com>
	 <1326797276.2259.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAGsizz+WG=NEc7kj7WoZP0Z-KgGwwiJS7kycHW6cxPeo9h88zA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?Q?=C5=A0tefan?= Gula <steweg@ynet.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizz+WG=NEc7kj7WoZP0Z-KgGwwiJS7kycHW6cxPeo9h88zA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 17 janvier 2012 =C3=A0 12:00 +0100, =C5=A0tefan Gula a =C3=A9c=
rit :

> >
> looks good... I am just wondering whether my previous question about
> the placement of calls for ipgre_tap_bridge_init and
> ipgre_tap_bridge_fini? Would it be also possible to have this
> done/fixed when I migrate those inside the ipgre_init and ipgre_fini =
?
> I would like to have much rather identical parts of code with standar=
d
> bridge code just in case somebody would start doing generalization of
> bridge code which can be then reused anywhere inside the kernel space
> - simpler migration process later.

Could you please stop claiming this is the same than bridge ?

There is _one_ exit function per module (ipgre_fini in ip_gre)

You wanted to destroy your kmem_cache only from this __exit function,
not from the pernet exit function (ipgre_exit_net)
