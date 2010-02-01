From: John Kacur <jkacur@gmail.com>
Subject: Re: [PATCH] irda: remove BKL from irnet open function
Date: Mon, 1 Feb 2010 21:32:30 +0100
Message-ID: <520f0cf11002011232u415146a9md3afe65af4d810a6@mail.gmail.com>
References: <1265048321-8097-1-git-send-email-cascardo@holoscopio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd@arndb.de>, Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f228.google.com ([209.85.219.228]:44461 "EHLO
	mail-ew0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756158Ab0BAUcb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 15:32:31 -0500
In-Reply-To: <1265048321-8097-1-git-send-email-cascardo@holoscopio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 1, 2010 at 7:18 PM, Thadeu Lima de Souza Cascardo
<cascardo@holoscopio.com> wrote:
> Commit cddf63d99d0d145f18b293c3d0de4af7dab2a922 has push down the BKL
> into irnet open function. However, there's nothing that needs locking=
 in
> there.
>
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com=
>
> ---
> =A0net/irda/irnet/irnet_ppp.c | =A0 =A03 ---
> =A01 files changed, 0 insertions(+), 3 deletions(-)
>
> diff --git a/net/irda/irnet/irnet_ppp.c b/net/irda/irnet/irnet_ppp.c
> index 156020d..d6b502c 100644
> --- a/net/irda/irnet/irnet_ppp.c
> +++ b/net/irda/irnet/irnet_ppp.c
> @@ -479,7 +479,6 @@ dev_irnet_open(struct inode * =A0 =A0 =A0 inode,
> =A0 ap =3D kzalloc(sizeof(*ap), GFP_KERNEL);
> =A0 DABORT(ap =3D=3D NULL, -ENOMEM, FS_ERROR, "Can't allocate struct =
irnet...\n");
>
> - =A0lock_kernel();
> =A0 /* initialize the irnet structure */
> =A0 ap->file =3D file;
>
> @@ -501,7 +500,6 @@ dev_irnet_open(struct inode * =A0 =A0 =A0 inode,
> =A0 =A0 {
> =A0 =A0 =A0 DERROR(FS_ERROR, "Can't setup IrDA link...\n");
> =A0 =A0 =A0 kfree(ap);
> - =A0 =A0 =A0unlock_kernel();
> =A0 =A0 =A0 return err;
> =A0 =A0 }
>
> @@ -512,7 +510,6 @@ dev_irnet_open(struct inode * =A0 =A0 =A0 inode,
> =A0 file->private_data =3D ap;
>
> =A0 DEXIT(FS_TRACE, " - ap=3D0x%p\n", ap);
> - =A0unlock_kernel();
> =A0 return 0;
> =A0}
>
> --
> 1.6.6.1

This is probably NOT safe to do, because the BKL is synchronizing the
ioctl code.

Thanks
