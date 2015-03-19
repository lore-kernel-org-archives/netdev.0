From: Don Fry <pcnet32@frontier.com>
Subject: Re: [PATCH] net: ethernet: pcnet32: Setup the SRAM and NOUFLO on
 Am79C97{3,5}
Date: Wed, 18 Mar 2015 19:07:34 -0700
Message-ID: <1426730854.1840.23.camel@Lunix2.home>
References: <1426709407-16033-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
        stable@vger.kernel.org, linux-kernel@vger.kernel.org
To: Markos Chandras <markos.chandras@imgtec.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1426709407-16033-1-git-send-email-markos.chandras@imgtec.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

One little change to the comment is needed.  See below

Don

On Wed, 2015-03-18 at 20:10 +0000, Markos Chandras wrote:
> On a MIPS Malta board, tons of fifo underflow errors have been observed
> when using u-boot as bootloader instead of YAMON. The reason for that
> is that YAMON used to set the pcnet device to SRAM mode but u-boot does
> not. As a result, the default Tx threshold (64 bytes) is now too small to
> keep the fifo relatively used and it can result to Tx fifo underflow errors.
> As a result of which, it's best to setup the SRAM on supported controllers
> so we can always use the NOUFLO bit.

> +	/*
> +	 * The Am79C973/Am79C975 controllers come with 12K of SRAM
> +	 * which we can use for the Tx/Rx buffers but most importantly,
> +	 * the use of SRAM allow us to use the BCR18:NOUFLO bit to avoid
> +	 * Tx fifo underflows.
> +	 */
> +	if (sram) {
> +		/*
> +		 * The SRAM is being configured in two steps. First we
> +		 * set the SRAM size in the BCR25:SRAM_SIZE bits. According
> +		 * to the datasheet, each bit corresponds to a 512-byte
> +		 * page so we can have at most 24 pages. The SRAM_SIZE
> +		 * corresponds holds the value of the upper 8 bits of
> +		 * the 16-bit SRAM size. The low 8-bits start at 0x00
> +		 * and end at 0xff. So the address range is from 0x0000
> +		 * up to 0x17ff. Therefore, the SRAM_SIZE is set to 0x17.
> +		 * The next step is to set the BCR24:SRAM_BND midway through
> +		 * so the Tx and Rx buffers can share the SRAM equally.
> +		 */

The comment specifies BCR24 but the code is changing BCR26 which matches
the documentation.  Please correct the comment to avoid confusion.

> +		a->write_bcr(ioaddr, 25, 0x17);
> +		a->write_bcr(ioaddr, 26, 0xc);
> +		/* And finally enable the NOUFLO bit */
