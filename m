From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCH net-next 3/4] ipv4: Use probe_size to check write queue
 data length
Date: Wed, 18 Mar 2015 09:37:05 +0800
Message-ID: <5508D6C1.2020302@gmail.com>
References: <1425978986-8512-1-git-send-email-fan.du@intel.com> <1425978986-8512-4-git-send-email-fan.du@intel.com> <CABrhC0=+c1XpVZZpRyhrFJmUwdf1mp1RtWUh+jV-Mg3GXDAqwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34281 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932214AbbCRBm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 21:42:29 -0400
Received: by pacwe9 with SMTP id we9so26406408pac.1
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 18:42:28 -0700 (PDT)
In-Reply-To: <CABrhC0=+c1XpVZZpRyhrFJmUwdf1mp1RtWUh+jV-Mg3GXDAqwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B403=E6=9C=8810=E6=97=A5 20:26, John Heffner =E5=86=
=99=E9=81=93:
> NACK.  From RFC4821:
>
>     In addition, the timely loss detection algorithms in most protoco=
ls
>     have pre-conditions that SHOULD be satisfied before sending a pro=
be.
>     For example, TCP Fast Retransmit is not robust unless there are
>     sufficient segments following a probe; that is, the sender SHOULD
>     have enough data queued and sufficient receiver window to send th=
e
>     probe plus at least Tcprexmtthresh [RFC2760] additional segments.
>     This restriction may inhibit probing in some protocol states, suc=
h as
>     too close to the end of a connection, or when the window is too
>     small.
>

Thanks for pointing this out for me.

My limit understanding is the extra segments is used to trigger fast re=
transmit,
and the conditions is the count of duplicate ack. Then why needs an ext=
ra one more
segment here besides 'reordering' segment to trigger this?

size_needed =3D probe_size + (tp->reordering + 1) * tp->mss_cache;
                                             ^^^
btw, any comments for the rest of patches?

--=20
=E5=A4=A9=E4=B8=8B=E8=8B=B1=E9=9B=84=E5=87=BA=E6=88=91=E8=BE=88=EF=BC=8C=
=E4=B8=80=E5=85=A5=E6=B1=9F=E6=B9=96=E5=B2=81=E6=9C=88=E5=82=AC=E3=80=82
=E9=B8=BF=E5=9B=BE=E9=9C=B8=E4=B8=9A=E8=B0=88=E7=AC=91=E9=97=B4=EF=BC=8C=
=E4=B8=8D=E8=83=9C=E4=BA=BA=E7=94=9F=E4=B8=80=E5=9C=BA=E9=86=89=E3=80=82
=E6=8F=90=E5=89=91=E8=B7=A8=E9=AA=91=E6=8C=A5=E9=AC=BC=E9=9B=A8=EF=BC=8C=
=E7=99=BD=E9=AA=A8=E5=A6=82=E5=B1=B1=E9=B8=9F=E6=83=8A=E9=A3=9E=E3=80=82
=E5=B0=98=E4=B8=96=E5=A6=82=E6=BD=AE=E4=BA=BA=E5=A6=82=E6=B0=B4=EF=BC=8C=
=E5=8F=AA=E5=8F=B9=E6=B1=9F=E6=B9=96=E5=87=A0=E4=BA=BA=E5=9B=9E=E3=80=82

=E6=9D=A5=EF=BC=8C=E5=B9=B2=E4=BA=86=E8=BF=99=E7=A2=97=E9=85=92=EF=BC=8C=
=E6=8E=A5=E7=9D=80=E8=A7=A3BUG!
