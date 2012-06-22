From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: net: qmi_wwan: bind to both control and data interface
Date: Fri, 22 Jun 2012 17:25:34 +0300
Message-ID: <20120622142534.GA19617@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:30421 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590Ab2FVOZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2012 10:25:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Bj=F8rn Mork,

The patch 230718bda1be: "net: qmi_wwan: bind to both control and data=20
interface" from Jun 19, 2012, leads to the following Smatch warning:
drivers/net/usb/qmi_wwan.c:206 qmi_wwan_bind()
	 error: potential NULL dereference 'cdc_union'.

drivers/net/usb/qmi_wwan.c
   205          /* verify CDC Union */
   206          if (desc->bInterfaceNumber !=3D cdc_union->bMasterInter=
face0) {
                                              ^^^^^^^^^

cdc_union is only non-NULL for USB_CDC_UNION_TYPE.  We used to check fo=
r
NULL here but your patch removes the check.  I just want to verify that
that was intended.

   207                  dev_err(&intf->dev, "bogus CDC Union: master=3D=
%u\n", cdc_union->bMasterInterface0);
   208                  goto err;
   209          }
   210 =20

regards,
dan carpenter
