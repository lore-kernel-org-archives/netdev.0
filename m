From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH] cdc-phonet: Don't leak in usbpn_open
Date: Wed, 8 Aug 2012 10:12:06 +0300
Message-ID: <201208081012.07772.remi@remlab.net>
References: <alpine.LNX.2.00.1208072354030.3227@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1208072354030.3227@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 8 ao=FBt 2012 00:56:26 Jesper Juhl, vous avez =E9crit :
> We allocate memory for 'req' with usb_alloc_urb() and then test
> 'if (!req || rx_submit(pnd, req, GFP_KERNEL | __GFP_COLD))'.
> If we enter that branch due to '!req' then there is no problem. But i=
f
> we enter the branch due to 'req' being !=3D 0 and the 'rx_submit()' c=
all
> being false, then we'll leak the memory we allocated.
> Deal with the leak by always calling 'usb_free_urb(req)' when enterin=
g
> the branch. If 'req' happens to be 0 then the call is harmless, if it
> is not 0 then we free the memory we allocated but don't need.
>
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Acked-by: R=E9mi Denis-Courmont <remi@remlab.net>

> ---
>  drivers/net/usb/cdc-phonet.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
>   Only compile tested due to lack of hardware.

Hardware won't help you much with testing the error case anyway.

--=20
R=E9mi Denis-Courmont, looking for a job
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
