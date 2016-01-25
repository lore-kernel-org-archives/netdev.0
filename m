From: Greg Ungerer <gerg@uclinux.org>
Subject: Re: [PATCH v2] net: fec: make driver endian-safe
Date: Mon, 25 Jan 2016 10:52:17 +1000
Message-ID: <56A571C1.5050905@uclinux.org>
References: <1453650757-27459-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Lucas Stach <l.stach@pengutronix.de>,
	Fugang Duan <B38611@freescale.com>,
	Arnd Bergmann <arnd@arndb.de>, Shawn Guo <shawnguo@kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from icp-osb-irony-out9.external.iinet.net.au ([203.59.1.226]:16743
	"EHLO icp-osb-irony-out9.external.iinet.net.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751723AbcAYBBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2016 20:01:32 -0500
In-Reply-To: <1453650757-27459-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

On 25/01/16 01:52, Johannes Berg wrote:
> The driver treats the device descriptors as CPU-endian, which appears
> to be correct with the default endianness on both ARM (typically LE)
> and PowerPC (typically BE) SoCs, indicating that the hardware block
> is generated differently. Add endianness annotations and byteswaps as
> necessary.
> 
> It's not clear that the ifdef there really is correct and shouldn't
> just be #ifdef CONFIG_ARM, but I also can't test on anything but the
> i.MX6 HummingBoard where this gets it working with a BE kernel.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

I tested this on a ColdFire (5208) target that uses this driver.
Simple testing showed it working with no problems. The ColdFire
SoC processors use a version of the FEC hardware module, and they
always run big-endian.

Regards
Greg


> ---
>  drivers/net/ethernet/freescale/Makefile   |   3 +
>  drivers/net/ethernet/freescale/fec.h      |  40 ++++++---
>  drivers/net/ethernet/freescale/fec_main.c | 130 ++++++++++++++++--------------
>  3 files changed, 101 insertions(+), 72 deletions(-)
