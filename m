From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Splice on blocking TCP sockets again..
Date: Wed, 30 Sep 2009 08:00:04 +0200
Message-ID: <4AC2F3E4.5000904@gmail.com>
References: <20090930004820.GC19540@obsidianresearch.com> <4AC2E481.5060509@gmail.com> <20090930054031.GY22310@obsidianresearch.com> <4AC2F1D9.1010801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Volker Lendecke <vl@samba.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48979 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbZI3GAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 02:00:14 -0400
In-Reply-To: <4AC2F1D9.1010801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Jason Gunthorpe a =E9crit :
>>> One way to handle this is to switch tcp_read() to use the underlyin=
g file O_NONBLOCK
>>> flag, as other socket operations do. And let SPLICE_F_NONBLOCK cont=
rol the pipe output only.
>=20
> arg, this was tcp_splice_read() of course
>=20
>> Thanks Eric, this seems reasonable from my userspace perspective.
>>
>> I admit I don't understand why SPLICE_F_NONBLOCK exists, it seems ve=
ry
>> un-unixy to have a syscall completely ignore the NONBLOCK flag of th=
e
>> fd it is called on. Ie setting NONBLOCK on the pipe itself does
>> nothing when using splice..
>>
>=20
> Hmm, good question, I dont have the answer but I'll digg one.
>=20

commit	29e350944fdc2dfca102500790d8ad6d6ff4f69d
splice: add SPLICE_F_NONBLOCK flag

It doesn't make the splice itself necessarily nonblocking (because the
actual file descriptors that are spliced from/to may block unless they
have the O_NONBLOCK flag set), but it makes the splice pipe operations
nonblocking.

Signed-off-by: Linus Torvalds <torvalds@osdl.org>


See Linus intention was pretty clear : O_NONBLOCK should be taken into =
account
by 'actual file that are spliced from/to', regardless of SPLICE_F_NONBL=
OCK flag

