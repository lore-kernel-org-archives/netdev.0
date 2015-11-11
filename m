From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Wed, 11 Nov 2015 14:35:21 +0000
Message-ID: <yw1xoaf0ob86.fsf@unicorn.mansr.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
	<20151110233448.GA8646@electric-eye.fr.zoreil.com>
	<yw1xio59pdw6.fsf@unicorn.mansr.com>
	<20151110.211121.422193831316296487.davem@davemloft.net>
	<yw1xa8qkpvy3.fsf@unicorn.mansr.com>
	<yw1x6118pu0o.fsf@unicorn.mansr.com>
	<1447248595.17135.98.camel@edumazet-glaptop2.roam.corp.google.com>
	<yw1x1tbwpry3.fsf@unicorn.mansr.com>
	<1447250961.17135.104.camel@edumazet-glaptop2.roam.corp.google.com>
	<yw1xsi4coc58.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, romieu@fr.zoreil.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slash.tmp@free.fr
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xsi4coc58.fsf@unicorn.mansr.com> (=?iso-8859-1?Q?=22M=E5n?=
 =?iso-8859-1?Q?s_Rullg=E5rd=22's?= message
	of "Wed, 11 Nov 2015 14:15:31 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

M=E5ns Rullg=E5rd <mans@mansr.com> writes:

> Eric Dumazet <eric.dumazet@gmail.com> writes:
>
>> On Wed, 2015-11-11 at 13:48 +0000, M=E5ns Rullg=E5rd wrote:
>>> Eric Dumazet <eric.dumazet@gmail.com> writes:
>>>=20
>>> > On Wed, 2015-11-11 at 13:04 +0000, M=E5ns Rullg=E5rd wrote:
>>> >
>>> >> I tried that, and throughput (as measured by iperf3) dropped by =
2%.
>>> >> Maybe I did something wrong.
>>> >
>>> > What link speed have you used, what was the throughput you got,
>>> > and is the receiver using the same NIC ?
>>>=20
>>> 1Gbps link, 640 Mbps TCP transmit throughput to a PC with Intel NIC=
=2E
>>> Why does it matter what NIC the receiver has?
>>
>> Because at 1Gb line rate, you better get GRO properly implemented in=
 the
>> receiver, so that TCP stack does not send one ACK every 2 MSS.
>>
>> Send speed is also dependent on the number of ACK packets the sender=
 has
>> to process.
>>
>> This is why I suggested you use napi_gro_receive() in your driver.
>
> FWIW, with UDP I get 650 Mbps.

It seems the on-chip interconnect is limiting memory bandwidth availabl=
e
to the Ethernet DMA.  If I increase the limits, I get 800 Mbps over TCP
and 850 Mbps over UDP with the driver posted here, the TCP case being
CPU bound in csum_partial_copy_from_user.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
