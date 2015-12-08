From: Edward Cree <ecree@solarflare.com>
Subject: Re: Checksum offload queries
Date: Tue, 8 Dec 2015 16:03:18 +0000
Message-ID: <5666FF46.6030702@solarflare.com>
References: <5665A848.9010001@solarflare.com>
 <CALx6S37+YVqpVL6XX2KCHZad84DGpqpL+K4LdDZr5H-feiyjow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:7287 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756874AbbLHQDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 11:03:24 -0500
In-Reply-To: <CALx6S37+YVqpVL6XX2KCHZad84DGpqpL+K4LdDZr5H-feiyjow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 17:29, Tom Herbert wrote:
> On Mon, Dec 7, 2015 at 7:39 AM, Edward Cree <ecree@solarflare.com> wrote:
>> 2) Transmit checksums.
> It's analogous to CHECKSUM_COMPLETE, NETIF_F_HW_CSUM works for all
> cases of checksum offload and any combination of protocol layering.
... until a protocol combination comes along that doesn't allow all but the innermost checksum to be 0.  NETIF_F_HW_CSUM is limited to one checksum per packet.
Though I suppose if you only care about offloading payload checksums, and are happy to checksum headers in software, you _could_ maybe have the stack (somehow) say "once you've filled in the checksum we specified with start/offset, add each of these constants (in ones complement) and fill into these corresponding locations".  That way, you can compute e.g. the difference between the inner and outer UDP checksums (for the example of UDP over VXLAN) without needing to know the checksum payload.  But it's not clear how you could pass these instructions to the driver without making struct sk_buff bigger (even replacing start/offset with a list head adds a few bytes, plus you have to allocate and free the list elements).  And walking a list might slow down the hardware too much for it to be wor
 thwhile.
> NETIF_F_IP[V6]_CSUM is limited and requires a lot of logic in both
> driver and HW to implement correctly.
But the HW already has the logic, and practically speaking it probably will for a long time to come, and NETIF_F_HW_CSUM _doesn't_ cover everything, only the innermost checksum.  Is there really no way to have both?  Or are outer checksums Officially Not Important?
