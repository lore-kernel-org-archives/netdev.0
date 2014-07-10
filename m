From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH v7 10/33] net: dummy - set name assign type
Date: Thu, 10 Jul 2014 12:12:28 +0200
Message-ID: <CAG-2HqWSRRfW1EygXd_1=eYFsTeDd3SsJBfF3BuH35hgGxogxA@mail.gmail.com>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
 <1404980258-30853-11-git-send-email-teg@jklm.no> <87pphdh85q.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>,
	dingtianhong <dingtianhong@huawei.com>,
	Tan Xiaojun <tanxiaojun@huawei.com>,
	WANG Cong <xiyou.wangcong@gmail.com>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87pphdh85q.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 10, 2014 at 11:31 AM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote=
:
> Tom Gundersen <teg@jklm.no> writes:
>
>> A fixed number of indistinguishable dummy devices are allocated at m=
odule init time,
>> the names are therefore PREDICTABLE rather than ENUM.
>
> OK?  So if I go do
>
>  modprobe dummy numdummies=3D2
>  ip link add type dummy
>  ip link add type dummy
>
> then I'd have dummy0 and dummy1 with NET_NAME_PREDICTABLE, but dummy2=
 and
> dummy3 with NET_NAME_ENUM (from your rtnetlink patch).

Correct. Granted, this is definitely a grey area (the distinction
between the name assign types is less important for virtual devices),
but I still think this makes sense:

The result of

modprobe dummy numdummies=3D2

is to create dummy0 and dummy1, always with the same names.

The result of

ip link add type dummy

is to create dummyX, where X depends on what came before.

> I think this just demonstrates that there aren't that many different
> name types.  There is no real difference between your NET_NAME_ENUM a=
nd
> NET_NAME_PREDICTABLE, resulting in arbitrary choices like this one.

It is true that in some cases the distinction is less important, but
that does not negate the usefulness: For instance, the kernel may
assign names to interfaces based on information provided by their
firmware. These names may be useful to keep, and it may be important
for userspace to be told that they are backed by something sensible.

> The same goes for NET_NAME_USER and NET_NAME_RENAMED. These are the s=
ame
> from a kernel point of view.

You mean to collapse the two, and just label renamed interfaces
NET_NAME_USER instead?

> If userspace wants to keep track of device
> name history then it is free to do so without any need for a RENAMED
> type.

Just for the record, I don't see how userspace can keep track of
device name history (as some of the history may predate userspace
being around). Getting the history is not important though, what we
care about is the nature of the current name.

Cheers,

Tom
