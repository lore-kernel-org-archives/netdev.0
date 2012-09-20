From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: call subdriver with control intf
 only
Date: Thu, 20 Sep 2012 17:54:54 -0400 (EDT)
Message-ID: <20120920.175454.1700471593150372802.davem@davemloft.net>
References: <1347308150-19088-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347308150-19088-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Mon, 10 Sep 2012 22:15:50 +0200

> This fixes a hang on suspend due to calling wdm_suspend on
> the unregistered data interface. The hang should have been
> a NULL pointer reference had it not been for a logic error
> in the cdc_wdm code.
>=20
>   commit 230718bd net: qmi_wwan: bind to both control and data interf=
ace
>=20
> changed qmi_wwan to use cdc_wdm as a subdriver for devices with
> a two-interface QMI/wwan function.  The commit failed to update
> qmi_wwan_suspend and qmi_wwan_resume, which were written to handle
> either a single combined interface function, or no subdriver at all.
>=20
> The result was that we called into the subdriver both when the
> control interface was suspended and when the data interface was
> suspended.  Calling the subdriver suspend function with an
> unregistered interface is not supported and will make the
> subdriver bug out.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
