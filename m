From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH RESEND net-next 0/3] huawei_cdc_ncm introduction
Date: Wed, 21 Aug 2013 22:26:24 +0200
Message-ID: <f8d9c9a9-86b1-475d-b4a3-fa6306ea9c1b@email.android.com>
References: <mrkiko.rs@gmail.com> <1377010256-19063-1-git-send-email-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Enrico Mioso <mrkiko.rs@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40757 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752116Ab3HUU0c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 16:26:32 -0400
In-Reply-To: <1377010256-19063-1-git-send-email-mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Mioso <mrkiko.rs@gmail.com> wrote:
>
>These patches are all related to the new huawei_cdc_ncm driver,
>supporting=20
>devices that use the NCM protocol as a transport layer for other
>protocols.=20
>this is the case of the Huawei E3131 3G modem.
>Thanks should go to bjorn and others who helped me with patience.
>
>Enrico Mioso (3):
>  net: cdc_ncm: Export cdc_ncm_{tx,rx}_fixup functions for re-use
>  net: huawei_cdc_ncm: Introduce the
>  net: cdc_ncm: remove non-standard NCM device IDs
>
> drivers/net/usb/Kconfig     |   11 +++++++++++
> drivers/net/usb/Makefile    |    1 +
> drivers/net/usb/cdc_ncm.c   |   17 ++++-------------
> include/linux/usb/cdc_ncm.h |    3 +++
> 4 files changed, 19 insertions(+), 13 deletions(-)

Just for the record: I strongly support this.

The Huawei devices were added to the cdc_ncm driver without any underst=
anding of the embedded management protocol. We initially believed that =
the devices could be managed through an associated serial port. Now tha=
t Enrico has found that this isn't necessarily true, and that the embed=
ded protocol is simply AT commands, it is clear that we should expose t=
he embedded protocol to userspace. The absolutely best way to do that i=
s by creating a new driver for these devices, reusing the parts of cdc-=
wdm and cdc-ncm which are common. Just like Enrico has done here.

Thanks for doing this!


Bj=C3=B8rn=20
