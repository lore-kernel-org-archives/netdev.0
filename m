From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: 2.6.14-rc5 e1000 and page allocation failures.. still
Date: Tue, 25 Oct 2005 16:40:34 -0400
Message-ID: <435E9842.3010604@tmr.com>
References: <50tDw-1FH-5@gated-at.bofh.it> <435C2D66.6030708@shaw.ca> <4807377b0510241528m6afc3501w9d98d66658a38973@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932364AbVJYUjX@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0510241528m6afc3501w9d98d66658a38973@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:
> On 10/23/05, Robert Hancock <hancockr@shaw.ca> wrote:
>=20
>>John B=E4ckstrand wrote:
>>
>>>Im seeing a massive amount of page allocation failures with 2.6.14-r=
c5,
>>>and also earlier kernels, see "E1000 - page allocation failure - sag=
a
>=20
> [snip]
>=20
>>It looks like you have enough memory free - the problem is that the
>>driver is allocating a block of memory with order 3, which is 8 pages=
=2E
>>Quite likely there are not enough contiguous free pages to satisfy th=
at.
>>
>>That's an awful big buffer size for a packet - I assume you're using
>>jumbo frames or something? Ideally the driver and hardware should be
>>able to allocate a buffer for those packets in multiple chunks, but I
>>have no idea if this is possible.
>=20
>=20
> the latest e1000 driver (6.2.15) from http://sf.net/projects/e1000
> fixes this by using multiple descriptors for jumbo frames, therefore
> only doing order 0 (single page) page allocations.
>=20
> let us know how it goes.
>=20
> BTW why is this so much more common with recent kernels?

I don't know why it's more common, but I agree that it seems so. I have=
=20
speculated that it may be related to 4k stack, but I can't even generat=
e=20
a credible wild-ass guess on that, much less find any evidence, so I=20
doubt that's much if any correlation.

Getting memory a page at a time is ugly, but it will probably work just=
=20
fine.

--=20
    -bill davidsen (davidsen@tmr.com)
"The secret to procrastination is to put things off until the
  last possible moment - but no longer"  -me
