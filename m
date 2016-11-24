From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: =?UTF-8?B?UmU6IOetlOWkjTogW3NjcjI2NTQ4Ml0gaXBfdHVubmVsLmM=?=
Date: Thu, 24 Nov 2016 09:38:22 -0800
Message-ID: <CAM_iQpUQ0F6hOuPFAVPJUhYKy1sYNr-FLxYgKJ15eDSmgWqKGg@mail.gmail.com>
References: <860a2905e7f7467f864e13839eb05222@imshyb02.MITRE.ORG>
 <F41877A268BCDE49BAEE2286FA8C269F6FECFB15@LETV-MBX-IDC09.letv.local>
 <CAM_iQpX7mU7gogGx1peYMoOQbp0CZgYmTZJt=uGFm0c0gviY5A@mail.gmail.com> <F41877A268BCDE49BAEE2286FA8C269F6FECFBBF@LETV-MBX-IDC09.letv.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "security@kernel.org" <security@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "cve-request@mitre.org" <cve-request@mitre.org>
To: =?UTF-8?B?TGl5YW5nIFl1ICjkuo7nq4vmtIsxKQ==?= <yuliyang1@le.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34835 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932584AbcKXRin (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 12:38:43 -0500
Received: by mail-io0-f176.google.com with SMTP id a124so89294565ioe.2
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 09:38:43 -0800 (PST)
In-Reply-To: <F41877A268BCDE49BAEE2286FA8C269F6FECFBBF@LETV-MBX-IDC09.letv.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 11:45 PM, Liyang Yu (=E4=BA=8E=E7=AB=8B=E6=B4=8B1) =
<yuliyang1@le.com> wrote:
> Yeah=EF=BC=8CI means that recreate the tunnel again,
> But I don=E2=80=99t think the patch can fix the bug. It only can make the=
 first packet received successed. And the follow packet will droped also.
> In function __gre_xmit  line 366
>   tunnel->o_seqno++;
>
> If you restart from UINT_MAX, the 'o_seqno' of second packet will return =
to 0 again.

The first packet after restart: o_seqno =3D=3D UINT_MAX, the other end: i_s=
eqno =3D 0
The second packet after restart: o_seqno =3D=3D 0, the other end: i_seqno =
=3D 1

So traffic should be back to normal.

UINT_MAX is also what RFC suggests.
