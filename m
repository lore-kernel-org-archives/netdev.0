From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: define __packed for the userspace code
Date: Mon, 23 Aug 2010 10:29:49 +0800
Message-ID: <AANLkTikBcuYa_HNzhYYG62CLjcfptQNQM_zOsv9fXRfS@mail.gmail.com>
References: <AANLkTin1BOgHBc4sTwFAmQhKFNvZ+90herc4Dsh9P8y2@mail.gmail.com>
 <201008221507.42023.arnd@arndb.de> <AANLkTiktOcAvAxcXUxh+4jKh0nBmYCf0OVG0wqRNMb9T@mail.gmail.com>
 <20100822.183624.28802617.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arnd@arndb.de, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100822.183624.28802617.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 23, 2010 at 9:36 AM, David Miller <davem@davemloft.net> wro=
te:
>
> I don't think this it the reason it was being used here.
>
> Any, for one thing, we definitely cannot remove the existing packed
> markers or else we will break every single userland tool out there
> using these socket address structures.
>
> Even the first two members (sa_family_t and unsigned int) will be
> positioned differently if we remove the marker.
>
> I suspect the packed attribute is there to make sure the pppo* socket
> address structures fit within the generic socket address object size.
> (see struct __kernel_sockaddr_storage and struct sockaddr).
>
> As to the problem at-hand, I think we need to use __attribute__((pack=
ed))
> here. =A0And that's what I'll commit into net-2.6 and net-next-2.6
>

Do you mean that use the __attribute__((packed)) annotation in all of
these files:

localhost linux # grep "\<__packed\>" usr/include/ -r | uniq
usr/include/linux/if_hippi.h:} __packed;
usr/include/linux/if_fddi.h:} __packed;
usr/include/linux/nbd.h:} __packed;
usr/include/linux/ncp.h:} __packed;
usr/include/linux/rfkill.h:} __packed;
usr/include/linux/if_pppox.h:} __packed;
usr/include/linux/phonet.h:} __packed;
usr/include/linux/ipv6.h:} __packed;    /* required for some archs */
usr/include/linux/ipv6.h:} __packed;
usr/include/linux/if_ether.h:} __packed;

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
