From: Grant Grundler <grundler@chromium.org>
Subject: Re: [PATCH 2/2] asix: fix setting custom MAC address on Asix 88178 devices
Date: Tue, 10 Jan 2012 10:43:43 -0800
Message-ID: <CANEJEGvir0ppAA5V3y=iGE5k_d4F6f0dy-QiForYwoi+e+DiRw@mail.gmail.com>
References: <20120110164017.24658.9965.stgit@localhost6.localdomain6>
	<20120110164023.24658.76719.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Allan Chou <allan@asix.com.tw>,
	"David S. Miller" <davem@davemloft.net>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:53699 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932127Ab2AJSno convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 13:43:44 -0500
Received: by obcwo16 with SMTP id wo16so5878988obc.19
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2012 10:43:43 -0800 (PST)
In-Reply-To: <20120110164023.24658.76719.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2012 at 8:40 AM, Jussi Kivilinna
<jussi.kivilinna@mbnet.fi> wrote:
> (Note: only compile tested, I don't have 88178 device to confirm that=
 this
> patch works. Please, test.)
>
> ---
>
> In kernel v3.2 initialization sequence for Asix 88178 devices was cha=
nged so
> that hardware is reseted on every time interface is brought up (ifcon=
fig up),
> instead just at USB probe time. This causes problem with setting cust=
om MAC
> address to device as ax88178_reset causes reload of MAC address from =
EEPROM.
>
> This patch fixes the issue by rewriting MAC address at end of ax88178=
_reset.
>
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> Cc: Grant Grundler <grundler@chromium.org>

Acked-by: Grant Grundler <grundler@chromium.org>

Built with 3.0.13 based kernel and tested *once* on Samsung Series 5
w/AX88178 dongle (NWU220G)
Link comes up and DHCP works.

thanks,
grant

> Cc: Allan Chou <allan@asix.com.tw>
> Cc: stable <stable@vger.kernel.org>
> ---
> =C2=A0drivers/net/usb/asix.c | =C2=A0 =C2=A07 +++++++
> =C2=A01 files changed, 7 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
> index eb6b4c1..4736425 100644
> --- a/drivers/net/usb/asix.c
> +++ b/drivers/net/usb/asix.c
> @@ -1324,6 +1324,13 @@ static int ax88178_reset(struct usbnet *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret < 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
>
> + =C2=A0 =C2=A0 =C2=A0 /* Rewrite MAC address */
> + =C2=A0 =C2=A0 =C2=A0 memcpy(data->mac_addr, dev->net->dev_addr, ETH=
_ALEN);
> + =C2=A0 =C2=A0 =C2=A0 ret =3D asix_write_cmd(dev, AX_CMD_WRITE_NODE_=
ID, 0, 0, ETH_ALEN,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 data->mac_addr);
> + =C2=A0 =C2=A0 =C2=A0 if (ret < 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D asix_write_rx_ctl(dev, AX_DEFAULT_=
RX_CTL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret < 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
>
