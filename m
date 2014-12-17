From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: Bug: mv643xxx fails with highmem
Date: Wed, 17 Dec 2014 18:18:58 -0300
Message-ID: <5491F342.5090301@free-electrons.com>
References: <20141211194920.GR11285@n2100.arm.linux.org.uk> <20141211.151055.817876561546126576.davem@davemloft.net> <20141211202507.GS11285@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fugang.duan@freescale.com
To: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	Nimrod Andy <B38611@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:43342 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751076AbaLQVUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 16:20:51 -0500
In-Reply-To: <20141211202507.GS11285@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Russell, David:

On 12/11/2014 05:25 PM, Russell King - ARM Linux wrote:
> On Thu, Dec 11, 2014 at 03:10:55PM -0500, David Miller wrote:
>> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
>> Date: Thu, 11 Dec 2014 19:49:20 +0000
>>
>>> Commit 69ad0dd7af22 removed skb_frag_dma_map() in favour of mapping
>>> all fragments with dma_map_single().  This fails when the driver is
>>> used in an environment with highmem.
>>
>> This change looks really buggy to me.
>>
>> Unfortunately, all the changes he subsequently makes for software TS=
O
>> support depend upon this :-/
>>
>> The change is definitely wrong.

I've been trying to find a fix for this issue, and also trying to
reproduce the bug.

As for the fix, we need to fix the non-TSO and TSO paths independently.
The former is fairly straightforward, but the latter might be a bit mor=
e
involved.

The problem is that the tso_t struct holds a pointer to the skb linear
and non-linear data.

struct tso_t {
        int next_frag_idx;
        void *data;
        size_t size;
        u16 ip_id;
        u32 tcp_seq;
};

Instead, we should deal with pages, and only map the non-linear skb wit=
h
skb_frag_dma_map().

On the other side, I haven't been able to reproduce this on my boards. =
I
did try to put a hack to hold most lowmem pages, but it didn't make a
difference. (In fact, I haven't been able to clearly see how the pages
for the skbuff are allocated from high memory.)

Russell, would you share any hints about your setup? I don't have acces=
s
to any Dove boards at the moment, but I do have Kirkwoods, Armadas and
i.MX6.

Thanks a lot for your report and help!
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
