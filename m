From: Eric Dumazet <edumazet@google.com>
Subject: Re: [scr265482] ip_tunnel.c
Date: Thu, 24 Nov 2016 18:27:43 -0800
Message-ID: <CANn89iJKmO0oiJjw5y59B_DdA+4xzkbtVDWnz3NA8UvoSYt4Pw@mail.gmail.com>
References: <F41877A268BCDE49BAEE2286FA8C269F6FECFC5E@LETV-MBX-IDC09.letv.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        "security@kernel.org" <security@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "cve-request@mitre.org" <cve-request@mitre.org>
To: =?UTF-8?B?TGl5YW5nIFl1ICjkuo7nq4vmtIsxKQ==?= <yuliyang1@le.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35943 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751171AbcKYC1p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 21:27:45 -0500
Received: by mail-io0-f181.google.com with SMTP id x94so104555540ioi.3
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 18:27:44 -0800 (PST)
In-Reply-To: <F41877A268BCDE49BAEE2286FA8C269F6FECFC5E@LETV-MBX-IDC09.letv.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2016 at 5:39 PM, Liyang Yu (=E4=BA=8E=E7=AB=8B=E6=B4=8B1) <=
yuliyang1@le.com> wrote:
>
>
>
>
>
>
>
> BTW:
>
>    Which RFC suggests UINT_MAX as GRE sequence number?  Can you show me?
>
>
>
>
>
>


RFC 2890

In any cases, this is absolutely not a security issue nor a CVE candidate.
Please remove security@kernel.org from CC, no need to spam security guys,
they have enough on their plate.

Please send text messages, no HTML is allowed on netdev

Nobody sane uses GRE sequence numbers, precisely because GRE has
no documented way to synchronize the source and destination of the tunnel.
Basically, if you use GRE sequence numbers, you must re-start other side
of the tunnel if one side had to restart, or risk dropping up to 2^31 packe=
ts.

Really, this is not something that can be solved by using
'a different initial sequence number'

linux GRE sequence number support is a joke, it does not support SMP
for a start.



>
>
>
> On Wed, Nov 23, 2016 at 11:45 PM, Liyang Yu (=E4=BA=8E=E7=AB=8B=E6=B4=8B1=
) <yuliyang1@le.com> wrote:
>
> > Yeah=EF=BC=8CI means that recreate the tunnel again, But I don=E2=80=99=
t think the
>
> > patch can fix the bug. It only can make the first packet received succe=
ssed. And the follow packet will droped also.
>
> > In function __gre_xmit  line 366
>
> >   tunnel->o_seqno++;
>
> >
>
> > If you restart from UINT_MAX, the 'o_seqno' of second packet will retur=
n to 0 again.
>
>
>
> The first packet after restart: o_seqno =3D=3D UINT_MAX, the other end: i=
_seqno =3D 0 The second packet after restart: o_seqno =3D=3D 0, the other e=
nd: i_seqno =3D 1
>
>
>
> So traffic should be back to normal.
>
>
>
> UINT_MAX is also what RFC suggests.
