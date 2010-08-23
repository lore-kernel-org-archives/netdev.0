From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: define __packed for the userspace code
Date: Sun, 22 Aug 2010 18:36:24 -0700 (PDT)
Message-ID: <20100822.183624.28802617.davem@davemloft.net>
References: <AANLkTin1BOgHBc4sTwFAmQhKFNvZ+90herc4Dsh9P8y2@mail.gmail.com>
	<201008221507.42023.arnd@arndb.de>
	<AANLkTiktOcAvAxcXUxh+4jKh0nBmYCf0OVG0wqRNMb9T@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arnd@arndb.de, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTiktOcAvAxcXUxh+4jKh0nBmYCf0OVG0wqRNMb9T@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Changli Gao <xiaosuo@gmail.com>
Date: Sun, 22 Aug 2010 21:47:06 +0800

> On Sun, Aug 22, 2010 at 9:07 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> On Sunday 22 August 2010 13:23:42 Changli Gao wrote:
>>> On Sun, Aug 22, 2010 at 7:12 PM, Changli Gao <xiaosuo@gmail.com> wr=
ote:
>>> > This commit
>>> >
>>> > =A0commit bc10502dba37d3b210efd9f3867212298f13b78e
>>> > =A0Author: Eric Dumazet <eric.dumazet@gmail.com>
>>> > =A0Date: =A0 Thu Jun 3 03:21:52 2010 -0700
>>> >
>>> > =A0 =A0net: use __packed annotation
>>> >
>>> > makes use of __packed in the userspace code. So we'd better defin=
e __packed
>>> > for the userspace code too.
>>> >
>>>
>>> Oh, sorry. This patch can't work as include/linux/compiler.h isn't
>>> exported to the userspace. But where should we define __packed for =
the
>>> userspace code? include/linux/types.h?
>>
>> I would try to avoid making those structures packed to start with.
>> From what I can see, they structures annotated in the above commit
>> mostly don't even require explicit packing because they are already
>> packed. Not marking them packed makes the code portable to non-gcc
>> compilers.
>>
>=20
> Maybe __packed is used somewhere to hint that some members of a
> structure maybe unaligned.

I don't think this it the reason it was being used here.

Any, for one thing, we definitely cannot remove the existing packed
markers or else we will break every single userland tool out there
using these socket address structures.

Even the first two members (sa_family_t and unsigned int) will be
positioned differently if we remove the marker.

I suspect the packed attribute is there to make sure the pppo* socket
address structures fit within the generic socket address object size.
(see struct __kernel_sockaddr_storage and struct sockaddr).

As to the problem at-hand, I think we need to use __attribute__((packed=
))
here.  And that's what I'll commit into net-2.6 and net-next-2.6
