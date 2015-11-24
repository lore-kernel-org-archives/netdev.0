From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cdc_ncm: fix NULL pointer deref in
 cdc_ncm_bind_common
Date: Tue, 24 Nov 2015 14:26:47 -0500 (EST)
Message-ID: <20151124.142647.235443062760285159.davem@davemloft.net>
References: <1448285530-6223-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org, oneukum@suse.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753504AbbKXT0s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 14:26:48 -0500
In-Reply-To: <1448285530-6223-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Mon, 23 Nov 2015 14:32:10 +0100

> Commit 77b0a099674a ("cdc-ncm: use common parser") added a dangerous
> new trust in the CDC functional descriptors presented by the device,
> unconditionally assuming that any device handled by the driver has
> a CDC Union descriptor.
>=20
> This descriptor is required by the NCM and MBIM specs, but crashing
> on non-compliant devices is still unacceptable. Not only will that
> allow malicious devices to crash the kernel, but in this case it is
> also well known that there are non-compliant real devices on the
> market - as shown by the comment accompanying the IAD workaround
> in the same function.
>=20
> The Sierra Wireless EM7305 is an example of such device, having
> a CDC header and a CDC MBIM descriptor but no CDC Union:
 ...
> The conversion to a common parser also left the local cdc_union
> variable untouched.  This caused the IAD workaround code to be applie=
d
> to all devices with an IAD descriptor, which was never intended.  Fin=
ish
> the conversion by testing for hdr.usb_cdc_union_desc instead.
>=20
> Cc: Oliver Neukum <oneukum@suse.com>
> Fixes: 77b0a099674a ("cdc-ncm: use common parser")
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied, thanks.
