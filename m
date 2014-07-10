From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v7 10/33] net: dummy - set name assign type
Date: Thu, 10 Jul 2014 11:31:29 +0200
Message-ID: <87pphdh85q.fsf@nemi.mork.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
	<1404980258-30853-11-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>,
	dingtianhong <dingtianhong@huawei.com>,
	Tan Xiaojun <tanxiaojun@huawei.com>,
	WANG Cong <xiyou.wangcong@gmail.com>
To: Tom Gundersen <teg@jklm.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-11-git-send-email-teg@jklm.no> (Tom Gundersen's
	message of "Thu, 10 Jul 2014 10:17:15 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tom Gundersen <teg@jklm.no> writes:

> A fixed number of indistinguishable dummy devices are allocated at mo=
dule init time,
> the names are therefore PREDICTABLE rather than ENUM.

OK?  So if I go do

 modprobe dummy numdummies=3D2
 ip link add type dummy
 ip link add type dummy

then I'd have dummy0 and dummy1 with NET_NAME_PREDICTABLE, but dummy2 a=
nd
dummy3 with NET_NAME_ENUM (from your rtnetlink patch).

I think this just demonstrates that there aren't that many different
name types.  There is no real difference between your NET_NAME_ENUM and
NET_NAME_PREDICTABLE, resulting in arbitrary choices like this one.

The same goes for NET_NAME_USER and NET_NAME_RENAMED. These are the sam=
e
from a kernel point of view.  If userspace wants to keep track of devic=
e
name history then it is free to do so without any need for a RENAMED
type.


Bj=C3=B8rn
