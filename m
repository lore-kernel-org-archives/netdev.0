From: Ivo Van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH] rt2x00: Don't leak mem in error path of rt2x00lib_request_firmware()
Date: Tue, 11 Jan 2011 18:30:03 +0100
Message-ID: <AANLkTimDHO=oiR3ncX4BLmMJaoUAmaQL6r=bZcWV4-Gg@mail.gmail.com>
References: <alpine.LNX.2.00.1101110044580.32164@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:54691 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755463Ab1AKRaF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 12:30:05 -0500
In-Reply-To: <alpine.LNX.2.00.1101110044580.32164@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> We need to release_firmware() in order not to leak memory.
>
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

I can assume that release_firmware() checks if 'fw' is null?
If so:

Acked-by: Ivo van Doorn <IvDoorn@gmail.com>

> ---
> =A0rt2x00firmware.c | =A0 =A01 +
> =A01 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/wireless/rt2x00/rt2x00firmware.c b/drivers/n=
et/wireless/rt2x00/rt2x00firmware.c
> index f0e1eb7..be0ff78 100644
> --- a/drivers/net/wireless/rt2x00/rt2x00firmware.c
> +++ b/drivers/net/wireless/rt2x00/rt2x00firmware.c
> @@ -58,6 +58,7 @@ static int rt2x00lib_request_firmware(struct rt2x00=
_dev *rt2x00dev)
>
> =A0 =A0 =A0 =A0if (!fw || !fw->size || !fw->data) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ERROR(rt2x00dev, "Failed to read Firmw=
are.\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 release_firmware(fw);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOENT;
> =A0 =A0 =A0 =A0}
>
>
>
> --
> Jesper Juhl <jj@chaosbits.net> =A0 =A0 =A0 =A0 =A0 =A0http://www.chao=
sbits.net/
> Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
> Plain text mails only, please.
>
>
