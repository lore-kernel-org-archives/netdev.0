From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: net: qmi_wwan: bind to both control and data interface
Date: Fri, 22 Jun 2012 19:34:56 +0200
Message-ID: <87pq8rjlmn.fsf@nemi.mork.no>
References: <20120622142534.GA19617@elgon.mountain>
	<87395nl3bu.fsf@nemi.mork.no> <20120622165616.GI5390@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:50883 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754170Ab2FVRfB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2012 13:35:01 -0400
In-Reply-To: <20120622165616.GI5390@mwanda> (Dan Carpenter's message of "Fri,
	22 Jun 2012 19:56:17 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter <dan.carpenter@oracle.com> writes:
> On Fri, Jun 22, 2012 at 06:27:17PM +0200, Bj=C3=B8rn Mork wrote:
>
>> Thanks for the notification, but this was intentional while touching=
 the
>> code anyway.  The test always was redundant because the parsing code
>> ensure that cdc_union cannot be NULL at that point.
>>=20
>
> Yeah.  I see that now.  I think it would be more readable if the
> check were rewritten like this.  That way you can see immediately
> that it's checking for USB_CDC_UNION_TYPE without scrolling back and
> forth in the code.
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index f1e7791..23cb13c 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -129,7 +129,6 @@ static int qmi_wwan_bind(struct usbnet *dev, stru=
ct usb_interface *intf)
>  	struct usb_interface_descriptor *desc =3D &intf->cur_altsetting->de=
sc;
>  	struct usb_cdc_union_desc *cdc_union =3D NULL;
>  	struct usb_cdc_ether_desc *cdc_ether =3D NULL;
> -	u32 required =3D 1 << USB_CDC_HEADER_TYPE | 1 << USB_CDC_UNION_TYPE=
;
>  	u32 found =3D 0;
>  	struct usb_driver *driver =3D driver_of(intf);
>  	struct qmi_wwan_state *info =3D (void *)&dev->data;
> @@ -197,7 +196,8 @@ next_desc:
>  	}
> =20
>  	/* did we find all the required ones? */
> -	if ((found & required) !=3D required) {
> +	if (!(found & (1 << USB_CDC_HEADER_TYPE)) ||
> +	    !(found & (1 << USB_CDC_UNION_TYPE))) {
>  		dev_err(&intf->dev, "CDC functional descriptors missing\n");
>  		goto err;
>  	}


I fully agree.  Feel free to add my

Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>

if you want to submit that.



Bj=C3=B8rn
