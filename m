From: "Gao Feng" <gfree.wind@foxmail.com>
Subject: RE: [PATCH net 1/1] net: tcp: Don't increase the TCP_MIB_OUTRSTS when fail to transmit RST
Date: Thu, 6 Apr 2017 22:05:43 +0800
Message-ID: <001301d2aede$e1e54f00$a5afed00$@foxmail.com>
References: <1491485709-8269-1-git-send-email-gfree.wind@foxmail.com> <CADVnQymp9X3EwmiiocNHU8bQpg7Wb7FvGr4SduKjhLoTv35zMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: "'David Miller'" <davem@davemloft.net>,
        "'Alexey Kuznetsov'" <kuznet@ms2.inr.ac.ru>,
        "'James Morris'" <jmorris@namei.org>,
        "'Patrick McHardy'" <kaber@trash.net>,
        "'Netdev'" <netdev@vger.kernel.org>
To: "'Neal Cardwell'" <ncardwell@google.com>,
        "'Gao Feng'" <gfree.wind@foxmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg64.qq.com ([103.7.28.238]:8777 "EHLO smtpbg64.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934642AbdDFONt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 10:13:49 -0400
In-Reply-To: <CADVnQymp9X3EwmiiocNHU8bQpg7Wb7FvGr4SduKjhLoTv35zMA@mail.gmail.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neal,

> -----Original Message-----
> From: Neal Cardwell [mailto:ncardwell@google.com]
> Sent: Thursday, April 6, 2017 10:01 PM
> To: Gao Feng <gfree.wind@foxmail.com>
> Cc: David Miller <davem@davemloft.net>; Alexey Kuznetsov
> <kuznet@ms2.inr.ac.ru>; James Morris <jmorris@namei.org>; Patrick =
McHardy
> <kaber@trash.net>; Netdev <netdev@vger.kernel.org>; Gao Feng
> <fgao@ikuai8.com>
> Subject: Re: [PATCH net 1/1] net: tcp: Don't increase the =
TCP_MIB_OUTRSTS
> when fail to transmit RST
>=20
> On Thu, Apr 6, 2017 at 9:35 AM,  <gfree.wind@foxmail.com> wrote:
> > From: Gao Feng <fgao@ikuai8.com>
> >
> > When fail to transmit RST, don't increase TCP_MIB_OUTRSTS in func
> > tcp_send_active_reset like the case that it only increases
> > LINUX_MIB_TCPABORTFAILED when fail to alloc skb.
> >
> > Signed-off-by: Gao Feng <fgao@ikuai8.com>
> > ---
>=20
> I would be concerned that this is a change in the semantics of
> TCP_MIB_OUTRSTS that might break user-space monitoring tools that rely =
on
> the current semantics. Counting attempted RSTs could be an important =
signal
> to monitor, and it could be quite bad if that signal is lost or hidden =
because the
> machine is so overloaded that the transmission of the RSTs fails.
>=20
> Also it would seem to muddy the semantics a bit, since both
> tcp_v4_send_reset() and tcp_v6_send_response() currently increment
> TCP_MIB_OUTRSTS without regard to whether the transmit actually =
succeeded
> or not.
>=20
> neal
If so, we should increase the TCP_MIB_OUTRSTS too when fail to alloc =
skb.
When machine is overloaded and mem is exhausted, it may fail to alloc =
skb.

Regards
Feng
