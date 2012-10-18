From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next 00/14] Adding a USB CDC MBIM driver
Date: Thu, 18 Oct 2012 14:16:37 -0700
Message-ID: <20121018211637.GA31828@kroah.com>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Oliver Neukum <oliver@neukum.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Greg Suarez <gpsuarez2512@gmail.com>,
	"Fangxiaozhi (Franko)" <fangxiaozhi@huawei.com>,
	Dan Williams <dcbw@redhat.com>,
	Aleksander Morgado <aleksander@lanedo.com>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:51472 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755977Ab2JRVQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 17:16:51 -0400
Received: by mail-pb0-f46.google.com with SMTP id rr4so8712456pbb.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 14:16:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1350592867-25651-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 18, 2012 at 10:40:53PM +0200, Bj=F8rn Mork wrote:
> The USB Communications Device Class "Mobile Broadband Interface Model=
"
> (MBIM) is the USB-IFs alternative to the current chipset/vendor
> specific solutions to "Mobile Broadband" device management. The
> specification, including the management protocol description, can be
> downloaded from http://www.usb.org/developers/devclass_docs#approved
>=20
> This driver implementing most MBIM features with the exception of
> 32bit NTB and NDP headers.
>=20
> An important design principle has been reusing as much as possible of
> existing kernel code, in particular the cdc_ncm and cdc_wdm drivers.
> The CDC MBIM protocol is based on CDC NCM, and much of the setup and
> framing logic is very similar.
>=20
> One important addition in MBIM compared to NCM is the new control
> protocol embedded in CDC commands.  This protocol is comprehensive an=
d
> support a number of policy decisions necessary for modern mobile
> broadband devices often having multiple radio interfaces.  Based on
> early comments and the experiences with the qmi_wwan driver, knowledg=
e
> of the control protocol has been kept completely out of the driver.
> This is userspace material.  Like with qmi_wwan, a control protocol
> interface is exported to userspace using the cdc_wdm subdriver API,
> associating a /dev/cdc-wdmX character device with the network device
> for the management application.
>=20
> Patch 1 and 2 are independent of the rest and only required to make
> test devices with very large buffers work.
>=20
> Patch 3 adds new MBIM definitions to the cdc.h header file
>=20
> Patches 4 to 9 refactor the cdc_ncm driver to enable reusing common
> parts for MBIM.
>=20
> Patches 10 and 11 add the new cdc_mbim driver
>=20
> Patch 12 prevents cdc_ncm from binding to backward compatible MBIM
> devices
>=20
> Patches 13 and 14 extend the MBIM driver to support multiplexed
> sessions
>=20
> The changes to the cdc_ncm driver has been tested and verified to wor=
k
> with an Ericsson F5521gw device.  The new cdc_mbim driver has been
> tested with a Huawei E367u-2 device with MBIM firmware, and other
> currently undisclosed devices.

Very nice work, I don't have any objections to any of this, but I just
did a very high-level code review:

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
