From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 16:52:15 -0400 (EDT)
Message-ID: <20160510.165215.1602157973141296642.davem@davemloft.net>
References: <1462911770.5333.11.camel@redhat.com>
	<20160510.164538.1375529074383780155.davem@davemloft.net>
	<1462913455.16365.12.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pabeni@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com, jiri@mellanox.com, daniel@iogearbox.net,
	ast@plumgrid.com, aduyck@mirantis.com, tom@herbertland.com,
	peterz@infradead.org, mingo@kernel.org, hannes@stressinduktion.org,
	linux-kernel@vger.kernel.org
To: riel@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462913455.16365.12.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Rik van Riel <riel@redhat.com>
Date: Tue, 10 May 2016 16:50:56 -0400

> On Tue, 2016-05-10 at 16:45 -0400, David Miller wrote:
>> From: Paolo Abeni <pabeni@redhat.com>
>> Date: Tue, 10 May 2016 22:22:50 +0200
>>=20
>> > On Tue, 2016-05-10 at 09:08 -0700, Eric Dumazet wrote:
>> >> On Tue, 2016-05-10 at 18:03 +0200, Paolo Abeni wrote:
>> >>=A0
>> >> > If a single core host is under network flood, i.e. ksoftirqd is
>> >> > scheduled and it eventually (after processing ~640 packets) wil=
l
>> let the
>> >> > user space process run. The latter will execute a syscall to
>> receive a
>> >> > packet, which will have to disable/enable bh at least once and
>> that will
>> >> > cause the processing of another ~640 packets. To receive a
>> single packet
>> >> > in user space, the kernel has to process more than one thousand
>> packets.
>> >>=A0
>> >> Looks you found the bug then. Have you tried to fix it ?
>> =A0...
>> > The ksoftirq and the local_bh_enable() design are the root of the
>> > problem, they need to be touched/affected to solve it.
>>=20
>> That's not what I read from your description, processing 640 packets
>> before going to ksoftirqd seems to the be the absolute root problem.
>=20
> What would a fix for that look like?
>=20
> Keep track of the number of processed incoming packets,
> and the number of packets handed off, and defer to
> ksoftirqd earlier if the statistics suggest packets are
> getting dropped on the floor?

Not by packet count but by something more easily to measure and
scalable to fairness like processing time.
