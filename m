From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH/RFC v3 net] ravb: unmap descriptors when freeing rings
Date: Fri, 10 Feb 2017 14:52:50 +0100
Message-ID: <CAMuHMdVzN_6tfjD1eYBLzrpynupo6C2hnLv6mm5UzcdSNzWtyQ@mail.gmail.com>
References: <1485282073-16662-1-git-send-email-horms+renesas@verge.net.au> <312867f0-f6dd-3c92-df09-fae72ea7405b@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simon Horman <horms+renesas@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34842 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751858AbdBJN7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 08:59:04 -0500
In-Reply-To: <312867f0-f6dd-3c92-df09-fae72ea7405b@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2017 at 5:18 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 01/24/2017 09:21 PM, Simon Horman wrote:
>
>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>
>> "swiotlb buffer is full" errors occur after repeated initialisation of a
>> device - f.e. suspend/resume or ip link set up/down. This is because
>> memory
>> mapped using dma_map_single() in ravb_ring_format() and ravb_start_xmit()
>> is not released.  Resolve this problem by unmapping descriptors when
>> freeing rings.
>
>
>    Could you look into the sh_eth driver which seems to have the same issue?

Indeed, after a few suspend/resume cycles on r8a7791/koelsch:

WARNING: CPU: 1 PID: 1699 at lib/dma-debug.c:517 add_dma_entry+0xfc/0x148
DMA-API: exceeded 7 overlapping mappings of cacheline 0x0000000001a827e3

Gr{oetje,eeting}s,

                        Geert
