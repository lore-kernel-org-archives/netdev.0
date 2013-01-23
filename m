From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: cdc_mbim: send ZLP only for the specific
 buggy device
Date: Wed, 23 Jan 2013 13:47:26 -0500 (EST)
Message-ID: <20130123.134726.112187775032509711.davem@davemloft.net>
References: <1358938622-18344-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org, oneukum@suse.de,
	gsuarez@smithmicro.com, alexey.orishko@stericsson.com,
	y.kaliuta@gmail.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839Ab3AWSr3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 13:47:29 -0500
In-Reply-To: <1358938622-18344-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Wed, 23 Jan 2013 11:57:02 +0100

> Reverting 328d7b8 and instead adding an exception for the
> Sierra Wireless MC7710.
>=20
> commit 328d7b8 (net: cdc_mbim: send ZLP after max sized NTBs)
> added a workaround for an issue observed on one specific device.
> Concerns were raised that this workaround adds a performance
> penalty to all devices based on questionable, if not buggy,
> behaviour of a single device:
>=20
>  "If you add ZLP for NTBs of dwNtbOutMaxSize, you are heavily affecti=
ng CPU
>   load, increasing interrupt load by factor of 2 in high load traffic
>   scenario and possibly decreasing throughput for all other devices
>   which behaves correctly."
>=20
>  "The idea of NCM was to avoid extra ZLPs. If your transfer is exactl=
y
>   dwNtbOutMaxSize, it's known, you can submit such request on the rec=
eiver
>   side and you do not need any EOT indicatation, so the frametime can=
 be
>   used for useful data."
>=20
> Adding a device specific exception to prevent the workaround from
> affecting well behaved devices.
>=20
> The assumption here is that needing a ZLP is truly an *exception*.
> We do not yet have enough data to verify this.  The generic
> workaround in commit 328d7b8 should be considered acceptable despite
> the performance penalty if the exception list becomes a maintainance
> hassle.
>=20
> Cc: Alexey ORISHKO <alexey.orishko@stericsson.com>
> Cc: Yauheni Kaliuta <y.kaliuta@gmail.com>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied.
