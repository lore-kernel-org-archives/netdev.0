From: Eric Dumazet <edumazet@google.com>
Subject: Re: v4.14-rc3/arm64 DABT exception in atomic_inc() / __skb_clone()
Date: Wed, 25 Oct 2017 12:01:35 -0700
Message-ID: <CANn89iL-tcPUVDREwXCUR4hxVTBCP2HYJLzPGUGMTh5dpe0C6Q@mail.gmail.com>
References: <EAA60182-6F08-412E-8F8B-FD4B0309A858@gmail.com>
 <20171020111408.edj24tztxdptte5r@lakrids.cambridge.arm.com>
 <960D71EC-C1E9-4898-ACBE-543FC09483FF@gmail.com> <CACT4Y+bjzzCv3LSxK12C1xB8GfR3UYCrX_5phRYJ8fpxh9vcvQ@mail.gmail.com>
 <CAF=yD-K76TMjHiYRTRAnxM-x4LBcUDY+27WX477HW6kG=L_aZw@mail.gmail.com>
 <D2AD6D5B-3A05-48E7-A999-DECAB18A4649@gmail.com> <CAF=yD-JFjjA=2T7HermH2GygfHinyW+ZC5v+Di7M4V_Fg5paHg@mail.gmail.com>
 <CAF=yD-Lw2E7T12sA-dgMK5kn=L0TLGQE+v68s1X8HMHLq9hGBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Wei Wei <dotweiba@gmail.com>, Dmitry Vyukov <dvyukov@google.com>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-arm-kernel@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:54507 "EHLO
        mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932309AbdJYTBh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 15:01:37 -0400
Received: by mail-yw0-f171.google.com with SMTP id w5so891321ywg.11
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 12:01:36 -0700 (PDT)
In-Reply-To: <CAF=yD-Lw2E7T12sA-dgMK5kn=L0TLGQE+v68s1X8HMHLq9hGBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 11:49 AM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:

> From skb->dev and netdev_priv, the tun device has flags 0x1002 ==
> IFF_TAP | IFF_NO_PI. This kernel precedes the recent support for
> IFF_NAPI and IFF_NAPI_FRAGS. The allocation most likely happened
> in tun_build_skb from current->task_frag. It would be a previous
> allocation that left alloc_frag->offset unaligned. But perhaps this code
> needs to perform alignment before setting skb->head. At least on
> platforms where atomic on dataref must be aligned.

+1

Bug added in commit 66ccbc9c87c2 ("tap: use build_skb() for small packet")
