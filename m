From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Submission for S2io 10GbE driver
Date: Tue, 17 Feb 2004 00:11:12 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040217001111.A23086@infradead.org>
References: <20040205004952.GA27510@cup.hp.com> <000201c3f4d2$2a5ddd90$7410100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "'Andi Kleen'" <ak@suse.de>,
        "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Stephen Hemminger'" <shemminger@osdl.org>,
        "'Francois Romieu'" <romieu@fr.zoreil.com>,
        "'jamal'" <hadi@cyberus.ca>, "'Grant Grundler'" <iod00d@hp.com>,
        "'Anton Blanchard'" <anton@samba.org>,
        "'Jes Sorensen'" <jes@trained-monkey.org>,
        raghavendra.koushik@s2io.com,
        "'ravinandan arakali'" <ravinandan.arakali@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
Content-Disposition: inline
In-Reply-To: <000201c3f4d2$2a5ddd90$7410100a@S2IOtech.com>; from leonid.grossman@s2io.com on Mon, Feb 16, 2004 at 01:16:35PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A bunch of comments:

 - if you want to submit the driver for inclusion please submit a patch against a kernel tree,
   not a tarball.
 - please try to avoid version ifdefs by provoding the newer APIs on older kernels, e.g.:

#ifndef IRQ_RETVAL
#define irqreturn_t                     void
#define IRQ_RETVAL(foo)
#endif

#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,00)
#define free_netdev kfree
#endif

 - your AS_A_MODULE ifdef is bogs - everything under it is fine for a
   non-modular driver, too
 - your XENA_ARCH_64 is not good - just cast 64bit values to
   (unsigned long long) always and use the ll format specifier always.
   You missed a few 64bit arches, btw :)
 - can you get rid of all those BOOL/TRUE/FALSE/SUCCESS/etc.. ifdefs?
 - s2io_driver wants to be converted to C99 initializers (.foo instead of foo:)
 - In Linux comments usually are on the same indentation level as surrounding
   code
 - CONFIGURE_NAPI_SUPPORT should probably become CONFIG_XENA_NAPI or whatever
 - you want to use ethtool_ops instead of the ioctl variant
 - there's lots of non-static symbols in s2io.c - these shouldn't exist in a
   single source-file driver
 - you can't return -ENOMEM from the isr - just IRQ_HANDLED or IRQ_NONE
 - having the RCS log at the end of the source files looks ... odd
