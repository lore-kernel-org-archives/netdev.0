From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH 7/7] usbnet: qmi_wwan: don't recover device if suspend fails in system sleep
Date: Tue, 05 Mar 2013 08:09:35 +0100
Message-ID: <877glmqq4w.fsf@nemi.mork.no>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
	<1362456103-24956-8-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1362456103-24956-8-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> (Ming
	Lei's message of "Tue, 5 Mar 2013 12:01:43 +0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:

> If suspend callback fails in system sleep context, usb core will
> ignore the failure and let system sleep go ahead further, so
> this patch doesn't recover device under this situation.
>
> Cc: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  drivers/net/usb/qmi_wwan.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index efb5c7c..fce18be 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -294,7 +294,7 @@ static int qmi_wwan_suspend(struct usb_interface =
*intf, pm_message_t message)
> =20
>  	if (intf =3D=3D info->control && info->subdriver && info->subdriver=
->suspend)
>  		ret =3D info->subdriver->suspend(intf, message);
> -	if (ret < 0)
> +	if (ret < 0  && PMSG_IS_AUTO(msg))
>  		usbnet_resume(intf);
>  err:
>  	return ret;


NAK. We if the device cannot suspend, then it cannot do suspend halfway=
s
either. Whether the caller will ignore the error or not, is irrelevant.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
