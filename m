From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [PATCH] 3c59x: Don't assign when a comparison is intended
Date: Sat, 25 Dec 2010 21:50:56 +0100
Message-ID: <AANLkTi=Y4wDG6+AY1=8NuFLGuCidgqaU1LginfB1YpZH@mail.gmail.com>
References: <alpine.LNX.2.00.1012252125410.10759@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, vortex@scyld.com, becker@scyld.com,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	linux-kernel@vger.kernel.org
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:49798 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137Ab0LYUu5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 15:50:57 -0500
In-Reply-To: <alpine.LNX.2.00.1012252125410.10759@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 25, 2010 at 9:30 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> Hi,
>
> In drivers/net/3c59x.c::vortex_probe1() we have this code:
>
> =A0 =A0 =A0 =A0if (gendev) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((pdev =3D DEVICE_PCI(gendev))) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0print_name =3D pci_nam=
e(pdev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((edev =3D DEVICE_EISA(gendev))) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0print_name =3D dev_nam=
e(&edev->dev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> I believe these assignments were intended to be comparisons.
> If I'm correct, then here's a patch to fix that up.

I don't think so. Look at the extra brackets.

The code can also written as:

pdev =3D DEVICE_PCI(gendev);
if(pdev)
  print_name =3D pci_name(pdev);


>
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
> =A03c59x.c | =A0 =A04 ++--
> =A01 file changed, 2 insertions(+), 2 deletions(-)
> diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
> index 0a92436f..db8a80e 100644
> --- a/drivers/net/3c59x.c
> +++ b/drivers/net/3c59x.c
> @@ -1110,11 +1110,11 @@ static int __devinit vortex_probe1(struct dev=
ice *gendev,
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (gendev) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((pdev =3D DEVICE_PCI(gendev))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((pdev =3D=3D DEVICE_PCI(gendev))) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0print_name =3D pci_nam=
e(pdev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((edev =3D DEVICE_EISA(gendev))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((edev =3D=3D DEVICE_EISA(gendev))) =
{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0print_name =3D dev_nam=
e(&edev->dev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
>
> --
> Jesper Juhl <jj@chaosbits.net> =A0 =A0 =A0 =A0 =A0 =A0http://www.chao=
sbits.net/
> Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
> Plain text mails only, please.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>

--=20
Thanks,
//richard
