From: "allan" <allan@asix.com.tw>
Subject: RE: drivers/net/usb/asix: bug in asix_get_wol
Date: Sat, 17 Dec 2011 10:35:42 +0800
Message-ID: <001c01ccbc64$95f5d7d0$c1e18770$@com.tw>
References: <CAKbEaOBODRW1pL4OiwZTKOfqtPEhEOHBBwXQNWVoBh9zzLX9kQ@mail.gmail.com>	<CANEJEGud6++PGHRZGt1xMonX1XvxeU19Wd3YNsbgLQG+uQi47g@mail.gmail.com>	<CAKbEaOBnGAJuZiM5BRaR3RD6EzgB-mCVrC0v2AbnniFpx22m8A@mail.gmail.com>	<CANEJEGvz2ZHD_ZNJm_WeKCdVE9pmSQJY5dCe8hNayAS0MFN=-Q@mail.gmail.com>	<005201ccbbb1$cb242190$616c64b0$@com.tw> <CANEJEGvPqWVa+i9yfACU1Aoe1wdKCiO+dMtSgzcjiDqxM2ddRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'Eugene'" <elubarsky@gmail.com>, <netdev@vger.kernel.org>,
	"'Freddy Xin'" <freddy@asix.com.tw>,
	"=?utf-8?Q?'ASIX_Louis_=5B=E8=98=87=E5=A8=81=E9=99=B8=5D'?="
	<louis@asix.com.tw>
To: "'Grant Grundler'" <grundler@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from asix.com.tw ([113.196.140.82]:65448 "EHLO asix.com.tw"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756001Ab1LQCgA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 21:36:00 -0500
In-Reply-To: <CANEJEGvPqWVa+i9yfACU1Aoe1wdKCiO+dMtSgzcjiDqxM2ddRA@mail.gmail.com>
Content-Language: zh-tw
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Grant,

I will double check this issue and submit the revised patch to Linux ke=
rnel mainline source next week. Thanks a lot for your great helps.


---
Best regards,
Allan Chou
Technical Support Division
ASIX Electronics Corporation
TEL: 886-3-5799500 ext.228
=46AX: 886-3-5799558
E-mail: allan@asix.com.tw=20
http://www.asix.com.tw/=20

-----Original Message-----
=46rom: grundler@google.com [mailto:grundler@google.com] On Behalf Of G=
rant Grundler
Sent: Saturday, December 17, 2011 6:16 AM
To: ASIX Allan Email [office]
Cc: Eugene; netdev@vger.kernel.org; Freddy Xin; ASIX Louis [=E8=98=87=E5=
=A8=81=E9=99=B8]
Subject: Re: drivers/net/usb/asix: bug in asix_get_wol

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
>        struct usbnet *dev =3D netdev_priv(net);
>        u8 opt;
>
>        if (asix_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, &opt=
) < 0) {
>                wolinfo->supported =3D 0;
>                wolinfo->wolopts =3D 0;
>                return;
>        }
>        wolinfo->supported =3D WAKE_PHY | WAKE_MAGIC;
>        wolinfo->wolopts =3D 0;
>        if (opt & AX_MONITOR_LINK)
>                wolinfo->wolopts |=3D WAKE_PHY;
>        if (opt & AX_MONITOR_MAGIC)
>                wolinfo->wolopts |=3D WAKE_MAGIC;
> }

This looks remarkably similar to the code Eugene said enables WOL for
him (and it works). I not able to find any difference.

If you believe it was a mistake to remove these four lines of code,
please submit a patch (See Documentation/SubmittingPatches)  to add
them back. You can add a "Tested-by: Eugene <elubarsky@gmail.com>"
line after your own "Signed-off-by:" in the patch.

thanks!
grant
