From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] bcma: s&r: NULL mapped core
Date: Thu, 12 Jan 2012 23:53:03 -0800
Message-ID: <CA+55aFyLQGVxWGvs=ipm+YXc2VuNZ_EFSpdGF0OQNFN_7Hg14w@mail.gmail.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:63273 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151Ab2AMHxY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 02:53:24 -0500
Received: by ghbg16 with SMTP id g16so753488ghb.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 23:53:24 -0800 (PST)
In-Reply-To: <1326440480-26271-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yup. This definitely helps.

I haven't done a lot of suspend/resume cycles, and I have my own
cleanups in my tree, but with this, I finally get a successful resume.

I'll send out a series of cleanups and fixes that will include this.
Can you test whether my series works for you too?

               Linus

On Thu, Jan 12, 2012 at 11:41 PM, Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail=
=2Ecom> wrote:
> ---
> =C2=A0drivers/bcma/host_pci.c | =C2=A0 =C2=A05 +++++
> =C2=A01 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/bcma/host_pci.c b/drivers/bcma/host_pci.c
> index 443b83a..726e43d 100644
> --- a/drivers/bcma/host_pci.c
> +++ b/drivers/bcma/host_pci.c
> @@ -237,11 +237,16 @@ static void bcma_host_pci_remove(struct pci_dev=
 *dev)
> =C2=A0#ifdef CONFIG_PM
> =C2=A0static int bcma_host_pci_suspend(struct pci_dev *dev, pm_messag=
e_t state)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 struct bcma_bus *bus =3D pci_get_drvdata(dev);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Host specific */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_save_state(dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_disable_device(dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_power_state(dev, pci_choose_state(=
dev, state));
>
> + =C2=A0 =C2=A0 =C2=A0 /* Bus specific */
> + =C2=A0 =C2=A0 =C2=A0 bus->mapped_core =3D NULL;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
> --
> 1.7.7
>
