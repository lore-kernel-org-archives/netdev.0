From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v2, kernel version 3.2.1] Source mode for macvlan
 interface
Date: Tue, 24 Jan 2012 10:48:18 +0100
Message-ID: <1327398498.7231.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <29378065.3471327360294412.JavaMail.root@5-MeO-DMT.ynet.sk>
	 <1327362739.2587.15.camel@edumazet-laptop>
	 <CAGsizzLD=0t_J5m=CdZn8+1j6ZD_Nmz352kydDKDqQKDK5nxSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?Q?=C5=A0tefan?= Gula <steweg@ynet.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizzLD=0t_J5m=CdZn8+1j6ZD_Nmz352kydDKDqQKDK5nxSw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 24 janvier 2012 =C3=A0 10:07 +0100, =C5=A0tefan Gula a =C3=A9c=
rit :
> 2012/1/24 Eric Dumazet <eric.dumazet@gmail.com>:

> > How many 'sources' are expected per port ?
> >
> > Above a certain (small) threshold, macvlan_fill_info() will 'overfl=
ow'
> > skb capacity and return an error.
> >
> > Take a look at macvlan_get_size() ?
> There should be no defined limits on how many MAC addresses you can
> put under one macvlan interface - it should be fully dynamic. You are
> right about the function, but I have a difficulty with fixing that. I=
t
> is no problem to calculate the space needed to dump all mac-address,
> but I tried to check how many times is macvlan_get_size called and it
> is called only once per macvlan interface initialization, which is
> obviously wrong in my case as I need that number to be changed each
> time before fill_info is called. I tried to find and example how to
> managed that from other drivers, but I was unsuccessful. Do you have
> any idea?

Take a look at commit c7ac8679bec9
(rtnetlink: Compute and store minimum ifinfo dump size)

and maybe extend it if necessary ?
