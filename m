From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] MDIO: FSL_PQ_MDIO: Fix bug on incorrect offset of tbipa
 register
Date: Wed, 12 Jun 2013 17:08:29 +0200
Message-ID: <51B88EED.6090709@linutronix.de>
References: <1371041258-15298-1-git-send-email-ogabbay@advaoptical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, paulus@samba.org, leoli@freescale.com,
	galak@kernel.crashing.org, B38951@freescale.com,
	Dongsheng.Wang@freescale.com, stef.van.os@prodrive.nl,
	timur@tabi.org, davem@davemloft.net, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Oded Gabbay <ogabbay@advaoptical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371041258-15298-1-git-send-email-ogabbay@advaoptical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/12/2013 02:47 PM, Oded Gabbay wrote:
> This patch fixes a bug in the fsl_pq_mdio.c module and in relevant device-tree
> files regarding the correct offset of the tbipa register in the eTSEC
> controller in some of Freescale's PQ3 and QorIQ SoC.
> The bug happens when the mdio in the device tree is configured to be compatible
> to "fsl,gianfar-tbi". Because the mdio device in the device tree points to
> addresses 25520, 26520 or 27520 (depends on the controller ID), the variable
> priv->map at function fsl_pq_mdio_probe, points to that address. However,
> later in the function there is a write to register tbipa that is actually
> located at 25030, 26030 or 27030. Because the correct address is not io mapped,
> the contents are written to a different register in the controller.
> The fix sets the address of the mdio device to start at 25000, 26000 or 27000
> and changes the mii_offset field to 0x520 in the relevant entry
> (fsl,gianfar-tbi) of the fsl_pq_mdio_match array.
> 
> Note: This patch may break MDIO functionallity of some old Freescale's SoC
> until Freescale will fix their device tree files. Basically, every device tree
> which contains an mdio device that is compatible to "fsl,gianfar-tbi" should be
> examined.

Not as is.
Please add a check for the original address. If it has 0x520 at the end
print a warning and fix it up. Please add to the patch description
which register is modified instead if this patch is not applied.
Depending on how critical this it might has to go stable.

Sebastian
