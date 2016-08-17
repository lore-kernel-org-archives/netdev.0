From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 2/2] kaweth: fix oops upon failed memory allocation
Date: Wed, 17 Aug 2016 15:15:49 +0200
Message-ID: <87ziobk03e.fsf@miraculix.mork.no>
References: <1471427969-2355-1-git-send-email-oneukum@suse.com>
	<1471427969-2355-2-git-send-email-oneukum@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, stern@rowland.harvard.edu
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:59926 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752009AbcHQNRO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 09:17:14 -0400
In-Reply-To: <1471427969-2355-2-git-send-email-oneukum@suse.com> (Oliver
	Neukum's message of "Wed, 17 Aug 2016 11:59:29 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.com> writes:

> Just return an error upon failure.
>
> Signed-off-by: Oliver Neukum <oneukum@suse.com>
> ---
>  drivers/net/usb/kaweth.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
> index 37bf715..3cd6906 100644
> --- a/drivers/net/usb/kaweth.c
> +++ b/drivers/net/usb/kaweth.c
> @@ -1049,6 +1049,8 @@ static int kaweth_probe(
>  		/* Download the firmware */
>  		dev_info(dev, "Downloading firmware...\n");
>  		kaweth->firmware_buf =3D (__u8 *)__get_free_page(GFP_KERNEL);
> +		if (!kaweth->firmware_buf)
> +				return -ENOMEM;

Eh, that should be "goto err_free_netdev;", shouldn't it?



Bj=C3=B8rn
