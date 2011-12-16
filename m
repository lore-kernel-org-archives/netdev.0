From: Grant Grundler <grundler@chromium.org>
Subject: Re: drivers/net/usb/asix: bug in asix_get_wol
Date: Fri, 16 Dec 2011 14:15:59 -0800
Message-ID: <CANEJEGvPqWVa+i9yfACU1Aoe1wdKCiO+dMtSgzcjiDqxM2ddRA@mail.gmail.com>
References: <CAKbEaOBODRW1pL4OiwZTKOfqtPEhEOHBBwXQNWVoBh9zzLX9kQ@mail.gmail.com>
	<CANEJEGud6++PGHRZGt1xMonX1XvxeU19Wd3YNsbgLQG+uQi47g@mail.gmail.com>
	<CAKbEaOBnGAJuZiM5BRaR3RD6EzgB-mCVrC0v2AbnniFpx22m8A@mail.gmail.com>
	<CANEJEGvz2ZHD_ZNJm_WeKCdVE9pmSQJY5dCe8hNayAS0MFN=-Q@mail.gmail.com>
	<005201ccbbb1$cb242190$616c64b0$@com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eugene <elubarsky@gmail.com>, netdev@vger.kernel.org,
	Freddy Xin <freddy@asix.com.tw>,
	=?UTF-8?B?QVNJWCBMb3VpcyBb6JiH5aiB6Zm4XQ==?= <louis@asix.com.tw>
To: "ASIX Allan Email [office]" <allan@asix.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:41738 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756644Ab1LPWQA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 17:16:00 -0500
Received: by ggdk6 with SMTP id k6so3142383ggd.19
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 14:16:00 -0800 (PST)
In-Reply-To: <005201ccbbb1$cb242190$616c64b0$@com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2011 at 9:15 PM, ASIX Allan Email [office]
<allan@asix.com.tw> wrote:
> Resend without attachment due to below email server error.
=2E..
> -----Original Message-----
> From: ASIX Allan Email [office] [mailto:allan@asix.com.tw]
> Sent: Friday, December 16, 2011 11:38 AM
> To: 'Grant Grundler'; 'Eugene'
> Cc: 'netdev@vger.kernel.org'; 'Freddy Xin'; ASIX Louis [=E8=98=87=E5=A8=
=81=E9=99=B8]
> Subject: RE: drivers/net/usb/asix: bug in asix_get_wol
> Importance: High
>
> Dear Grant and Eugene,
>
> Please refer to the attached file and below statements to modify the
> asix_get_wol() routine and let us know if this suggestion can solve
> your issues or not? Thanks a lot.

Allan,
Thanks for the response but it doesn't answer my previous question.
Let me ask the same question differently.

Does WOL support in asix driver need more than the four lines of code?
Ie does MONITOR_MODE need to be enabled or anything like that?

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> static void
> asix_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct usbnet *dev =3D netdev_priv(net);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 opt;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (asix_read_cmd(dev, AX_CMD_READ_MONITOR=
_MODE, 0, 0, 1, &opt) < 0) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0wolinfo->suppo=
rted =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0wolinfo->wolop=
ts =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0wolinfo->supported =3D WAKE_PHY | WAKE_MAG=
IC;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0wolinfo->wolopts =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (opt & AX_MONITOR_LINK)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0wolinfo->wolop=
ts |=3D WAKE_PHY;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (opt & AX_MONITOR_MAGIC)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0wolinfo->wolop=
ts |=3D WAKE_MAGIC;
> }

This looks remarkably similar to the code Eugene said enables WOL for
him (and it works). I not able to find any difference.

If you believe it was a mistake to remove these four lines of code,
please submit a patch (See Documentation/SubmittingPatches)  to add
them back. You can add a "Tested-by: Eugene <elubarsky@gmail.com>"
line after your own "Signed-off-by:" in the patch.

thanks!
grant
