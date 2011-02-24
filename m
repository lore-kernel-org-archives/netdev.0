From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH V11 2/4] ptp: Added a clock that uses the eTSEC found on
 the MPC85xx.
Date: Thu, 24 Feb 2011 11:27:31 -0600
Message-ID: <20110224112731.2d9bf080@schlenkerla>
References: <cover.1298447722.git.richard.cochran@omicron.at>
	<be1f5e801e8cd0145dd23aadae7c2055bb3c1d47.1298447722.git.richard.cochran@omicron.at>
	<20110223165058.GE14597@angua.secretlab.ca>
	<20110223112612.30071995@schlenkerla>
	<20110223175459.GH14597@angua.secretlab.ca>
	<20110223132444.65dfdda4@schlenkerla>
	<20110224165004.GB15234@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Thomas Gleixner <tglx@linutronix.de>,
	Rodolfo Giometti <giometti@linux.it>,
	Arnd Bergmann <arnd@arndb.de>,
	Peter Zijlstra <peterz@infradead.org>,
	<linux-api@vger.kernel.org>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-kernel@vger.kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	Paul Mackerras <paulus@samba.org>,
	John Stultz <john.stultz@linaro.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, <netdev@vger.kernel.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Christoph Lameter <cl@linux.com>,
	<linuxppc-dev@lists.ozlabs.org>,
	David Miller <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110224165004.GB15234@riccoc20.at.omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 24 Feb 2011 17:50:04 +0100
Richard Cochran <richardcochran@gmail.com> wrote:

> On Wed, Feb 23, 2011 at 01:24:44PM -0600, Scott Wood wrote:
> > Whatever string is used should be written into a binding document.
> > 
> > fsl,etsec-v1.6-ptp seems like it would be just as good for that purpose.
> > 
> > Even just fsl,etsec-ptp will identify the binding, though it's lacking in
> > identifying the hardware (in the absence of access to the eTSEC ID
> > registers).
> 
> I read the conversation, and I don't mind admitting that I do not
> understand what you both are arguing/discussing about.
> 
> How should I set the strings?  Like this?
> 
> arch/powerpc/boot/dts/mpc8313erdb.dts:
> 	ptp_clock@24E00 {
> 		compatible = "fsl,mpc8313-etsec-ptp";
> 	}
> arch/powerpc/boot/dts/mpc8572ds.dts:
> 	ptp_clock@24E00 {
> 		compatible = "fsl,mpc8572-etsec-ptp";
> 	} 
> arch/powerpc/boot/dts/p2020ds.dts:
> 	ptp_clock@24E00 {
> 		compatible = "fsl,p2020ds-etsec-ptp";
> 	} 
> arch/powerpc/boot/dts/p2020rdb.dts:
> 	ptp_clock@24E00 {
> 		compatible = "fsl,p2020rdb-etsec-ptp";
> 	} 
> 
> drivers/net/gianfar_ptp.c:
> 
> static struct of_device_id match_table[] = {
> 	{ .compatible = "fsl,mpc8313-etsec-ptp" },
> 	{ .compatible = "fsl,mpc8572-etsec-ptp" },
> 	{ .compatible = "fsl,p2020ds-etsec-ptp" },
> 	{ .compatible = "fsl,p2020rdb-etsec-ptp" },
> 	{},
> };

Those last two are boards, not chips.  I don't think even Grant is asking
to take things that far.

My vote, if it goes in a separate node at all, is "fsl,etsec-ptp", and let
the driver use SVR.  Even encoding an etsec version in the compatible
string would be difficult, unless fixed up by u-boot, as it appears to
differ based on chip revision (and the chip manuals seem to often not match
the hardware regarding the advertised eTSEC revision) and we don't normally
have separate dts files for different revisions of the same chip.  Plus,
our docs (at least the public ones) don't seem to be very helpful in
determining what version of eTSEC implies what.

If you want to use chip-based compatibles instead, then use the actual name
of the chip.  You'll need to verify 100% compatibility if you want to claim
compatibility with another chip; it's probably easier/safer to just list
every single Freescale chip that has this type of PTP in a huge compatible
table, like PCI drivers do.

-Scott
