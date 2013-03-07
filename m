From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v2 5/7] usbnet: qmi_wwan: comments on suspend failure
Date: Thu, 07 Mar 2013 19:08:49 +0100
Message-ID: <871ubrjd5a.fsf@nemi.mork.no>
References: <1362672924-22975-1-git-send-email-ming.lei@canonical.com>
	<1362672924-22975-6-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1362672924-22975-6-git-send-email-ming.lei@canonical.com> (Ming
	Lei's message of "Fri, 8 Mar 2013 00:15:22 +0800")
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ming Lei <ming.lei@canonical.com> writes:

> If suspend callback fails in system sleep context, usb core will
> ignore the failure and let system sleep go ahead further, so
> this patch comments on the case and requires that both
> usbnet_suspend() and subdriver->suspend() MUST return 0 in
> system sleep context.
>
> Cc: Bj=C3=B8rn Mork <bjorn@mork.no>
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
> ---
>  drivers/net/usb/qmi_wwan.c |    5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index efb5c7c..8a60bdd 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -288,6 +288,11 @@ static int qmi_wwan_suspend(struct usb_interface=
 *intf, pm_message_t message)
>  	struct qmi_wwan_state *info =3D (void *)&dev->data;
>  	int ret;
> =20
> +	/*
> +	 * Both usbnet_suspend() and subdriver->suspend() MUST return 0
> +	 * in system sleep context, otherwise, the resume callback has
> +	 * to recover device from previous suspend failure.
> +	 */
>  	ret =3D usbnet_suspend(intf, message);
>  	if (ret < 0)
>  		goto err;

Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>
--
To unsubscribe from this list: send the line "unsubscribe linux-input" =
in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
