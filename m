From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v4] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Sat, 31 Oct 2015 18:44:02 +0000
Message-ID: <yw1xd1vuc1zh.fsf@unicorn.mansr.com>
References: <1446137333-1822-1-git-send-email-mans@mansr.com>
	<20151030222841.GA24712@electric-eye.fr.zoreil.com>
	<yw1xlhajauup.fsf@unicorn.mansr.com>
	<20151031180751.GA490@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:36866 "EHLO unicorn.mansr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750704AbbJaSoE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Oct 2015 14:44:04 -0400
In-Reply-To: <20151031180751.GA490@electric-eye.fr.zoreil.com> (Francois
	Romieu's message of "Sat, 31 Oct 2015 19:07:51 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rancois Romieu <romieu@fr.zoreil.com> writes:

> M=E5ns Rullg=E5rd <mans@mansr.com> :
>> Francois Romieu <romieu@fr.zoreil.com> writes:
> [...]
>> > It looks like it receives, then tries to allocate new resources. I=
f so
>> > it may deplete the ring and you should instead consider allocating=
 new
>> > resources first, then receive data if alloc + map suceeded.
>>=20
>> The hardware receives a frame and stores it in the provided DMA buff=
er,
>> then raises an interrupt and moves on to the next buffer.  When a bu=
ffer
>> is handed over to the network stack, a new one has to take its place=
 in
>> the DMA queue.  I'm not sure how you're suggesting this be done
>> differently.
>
> - The hardware raises an interrupt and moves on to the next packet
> - The driver allocates a new buffer - call it Bob - and maps it.
>   - If it succeeds
>     - The driver unmaps the received packet
>     - The driver hands the received packet to the network stack
>     - The driver hands Bob to the hardware
>   - It it fails
>     - The driver updates the dropped packet stats
>     - The driver recycles the received - yet non-unmapped - packet to=
 the
>       hardware

Oh, I see.  That's better.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
