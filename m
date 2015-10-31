From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v4] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Sat, 31 Oct 2015 19:07:51 +0100
Message-ID: <20151031180751.GA490@electric-eye.fr.zoreil.com>
References: <1446137333-1822-1-git-send-email-mans@mansr.com>
 <20151030222841.GA24712@electric-eye.fr.zoreil.com>
 <yw1xlhajauup.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?utf-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35323 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbbJaSHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Oct 2015 14:07:55 -0400
Content-Disposition: inline
In-Reply-To: <yw1xlhajauup.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

M=C3=A5ns Rullg=C3=A5rd <mans@mansr.com> :
> Francois Romieu <romieu@fr.zoreil.com> writes:
[...]
> > It looks like it receives, then tries to allocate new resources. If=
 so
> > it may deplete the ring and you should instead consider allocating =
new
> > resources first, then receive data if alloc + map suceeded.
>=20
> The hardware receives a frame and stores it in the provided DMA buffe=
r,
> then raises an interrupt and moves on to the next buffer.  When a buf=
fer
> is handed over to the network stack, a new one has to take its place =
in
> the DMA queue.  I'm not sure how you're suggesting this be done
> differently.

- The hardware raises an interrupt and moves on to the next packet
- The driver allocates a new buffer - call it Bob - and maps it.
  - If it succeeds
    - The driver unmaps the received packet
    - The driver hands the received packet to the network stack
    - The driver hands Bob to the hardware
  - It it fails
    - The driver updates the dropped packet stats
    - The driver recycles the received - yet non-unmapped - packet to t=
he
      hardware

--=20
Ueimor
