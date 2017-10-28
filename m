From: Wei Wei <dotweiba@gmail.com>
Subject: Re: [PATCH V2 net] tuntap: properly align skb->head before building
 skb
Date: Sat, 28 Oct 2017 18:20:54 -0400
Message-ID: <06D9B61F-5C89-47C4-A060-B63FE5A8F922@gmail.com>
References: <1509073544-4474-1-git-send-email-jasowang@redhat.com>
 <20171028.190615.1780763141354795593.davem@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: jasowang@redhat.com, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Mark Rutland <mark.rutland@arm.com>
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:53897 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751273AbdJ1WVB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 18:21:01 -0400
In-Reply-To: <20171028.190615.1780763141354795593.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch, the crash can=E2=80=99t be reproduced with the =
syz-repro and crash log0/log1.

The auto-generated reproducers are here:=20
https://github.com/dotweiba/skb_clone_atomic_inc_bug

Thanks,
Wei
> On 28 Oct 2017, at 6:06 AM, David Miller <davem@redhat.com> wrote:
>=20
> From: Jason Wang <jasowang@redhat.com>
> Date: Fri, 27 Oct 2017 11:05:44 +0800
>=20
>> An unaligned alloc_frag->offset caused by previous allocation will
>> result an unaligned skb->head. This will lead unaligned
>> skb_shared_info and then unaligned dataref which requires to be
>> aligned for accessing on some architecture. Fix this by aligning
>> alloc_frag->offset before the frag refilling.
>>=20
>> Fixes: 0bbd7dad34f8 ("tun: make tun_build_skb() thread safe")
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
>> Cc: Wei Wei <dotweiba@gmail.com>
>> Cc: Dmitry Vyukov <dvyukov@google.com>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Reported-by: Wei Wei <dotweiba@gmail.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>=20
> Applied and queued up for -stable, thanks Jason.
