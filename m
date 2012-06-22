From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: net: qmi_wwan: bind to both control and data interface
Date: Fri, 22 Jun 2012 18:27:17 +0200
Message-ID: <87395nl3bu.fsf@nemi.mork.no>
References: <20120622142534.GA19617@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49971 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755826Ab2FVQ1W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2012 12:27:22 -0400
In-Reply-To: <20120622142534.GA19617@elgon.mountain> (Dan Carpenter's message
	of "Fri, 22 Jun 2012 17:25:34 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter <dan.carpenter@oracle.com> writes:

> The patch 230718bda1be: "net: qmi_wwan: bind to both control and data=
=20
> interface" from Jun 19, 2012, leads to the following Smatch warning:
> drivers/net/usb/qmi_wwan.c:206 qmi_wwan_bind()
> 	 error: potential NULL dereference 'cdc_union'.
>
> drivers/net/usb/qmi_wwan.c
>    205          /* verify CDC Union */
>    206          if (desc->bInterfaceNumber !=3D cdc_union->bMasterInt=
erface0) {
>                                               ^^^^^^^^^
>
> cdc_union is only non-NULL for USB_CDC_UNION_TYPE.  We used to check =
for
> NULL here but your patch removes the check.  I just want to verify th=
at
> that was intended.
>
>    207                  dev_err(&intf->dev, "bogus CDC Union: master=3D=
%u\n", cdc_union->bMasterInterface0);
>    208                  goto err;
>    209          }
>    210 =20

Thanks for the notification, but this was intentional while touching th=
e
code anyway.  The test always was redundant because the parsing code
ensure that cdc_union cannot be NULL at that point.


Bj=C3=B8rn
