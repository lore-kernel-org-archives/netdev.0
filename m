From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Potential out-of-bounds access in ip6_finish_output2
Date: Tue, 22 Apr 2014 14:00:06 +0200
Message-ID: <20140422120006.GA1960@order.stressinduktion.org>
References: <CA+FTKhu_zEWrd8Zc4dj91D2fOmhwOQoH-W7byMpn1usJ1gZ6MA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>, yoshfuji@linux-ipv6.org,
	maze@google.com, edumazet@google.com, brutus@google.com
To: Alexey Preobrazhensky <preobr@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59412 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755680AbaDVMAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 08:00:07 -0400
Content-Disposition: inline
In-Reply-To: <CA+FTKhu_zEWrd8Zc4dj91D2fOmhwOQoH-W7byMpn1usJ1gZ6MA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 21, 2014 at 05:22:05PM +0400, Alexey Preobrazhensky wrote:
> Hi,
>=20
> I=E2=80=99m working on AddressSanitizer[1] -- a tool that detects
> use-after-free and out-of-bounds bugs in kernel.
>=20
> I=E2=80=99ve encountered a heap-buffer-overflow in ip6_finish_output2=
 in linux
> kernel 3.14 (revision 455c6fdbd219161bd09b1165f11699d6d73de11c). A
> similar problem was reported earlier[2] and resulted in a patch[3],
> but we=E2=80=99ve hit this report again, so it seems the issue weren=E2=
=80=99t fixed,
> or there is another issue. The offending code in
> include/net/neighbour.h:401 is:
>=20
> do {
>         seq =3D read_seqbegin(&hh->hh_lock);
>         hh_len =3D hh->hh_len;
>         if (likely(hh_len <=3D HH_DATA_MOD)) {
>                 /* this is inlined by gcc */
> /* 401: */    memcpy(skb->data - HH_DATA_MOD, hh->hh_data, HH_DATA_MO=
D);
>         } else {
>                 int hh_alen =3D HH_DATA_ALIGN(hh_len);
>=20
>                 memcpy(skb->data - hh_alen, hh->hh_data, hh_alen);
>         }
> } while (read_seqretry(&hh->hh_lock, seq));
>=20
> This heap-buffer-overflow was triggered under trinity syscall fuzzer,
> so there is no reproducer. The report is followed by crash (included)=
=2E
>=20
> It would be great if someone familiar with the code took time to look
> into this report.

Thanks for the report!

By only looking at the report I doubt it is the same problem. I still h=
ave a
lot of mails to catch up but hope that I can audit the code in the next=
 days.

Thanks,

  Hannes
