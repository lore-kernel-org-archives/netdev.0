From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Sat, 23 Jun 2012 11:32:32 +0800
Message-ID: <CACVXFVNmquD6nhcJkumZsnXH7T+Ga3YNt9EAQ=-5HUkYwEdp7w@mail.gmail.com>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?ISO-8859-1?Q?Marius_Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1340356279-3124-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 22, 2012 at 5:11 PM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:

>
> Reported-by: Marius Bj=F8rnstad Kotsbak <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # v3.4
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> ---
> =A0drivers/net/usb/qmi_wwan.c | =A0 =A04 ++++
> =A01 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index 3767a12..b01960f 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -197,6 +197,10 @@ err:
> =A0static int qmi_wwan_cdc_wdm_manage_power(struct usb_interface *int=
f, int on)
> =A0{
> =A0 =A0 =A0 =A0struct usbnet *dev =3D usb_get_intfdata(intf);
> +
> + =A0 =A0 =A0 /* can be called while disconnecting */
> + =A0 =A0 =A0 if (!dev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> =A0 =A0 =A0 =A0return qmi_wwan_manage_power(dev, on);
> =A0}

Considered there isn't any protection between usbnet_disconnet and
wdm_open/wdm_close, you patch still doesn't work on the race, see
below:

   + =A0 =A0 =A0 if (!dev)
   + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;

            -> usbnet_disconnect() triggered and completed, so


=A0 =A0 =A0 =A0     return qmi_wwan_manage_power(dev, on);




Thanks,
--=20
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
