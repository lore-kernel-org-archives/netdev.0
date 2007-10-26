From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 1/14 v2] nes: module and device
	initialization
Date: Fri, 26 Oct 2007 16:23:23 -0700
Message-ID: <adatzodxxxw.fsf@cisco.com>
References: <200710192001.l9JK1U8O021689@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ewg@lists.openfabrics.org,
	general@lists.openfabrics.org
To: ggrundstrom@neteffect.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <200710192001.l9JK1U8O021689@neteffect.com>
	(ggrundstrom@neteffect.com's message of "Fri,
	19 Oct 2007 15:01:30 -0500")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

OK, a couple quick review comments and a process comment too:

 - First step in the driver is to kill off a lot of the #ifdefs:

 > +#ifdef IRQF_SHARED

The upstream driver really shouldn't have compatibility gunk for older
kernels... just make it build against the kernel it's in.

 > +#ifdef OFED_1_2

Same... kernel code shouldn't worry about OFED.

 > +#ifdef CONFIG_PCI_MSI
 > +	if (nesdev->msi_enabled) {
 > +		pci_disable_msi(pcidev);
 > +	}
 > +#endif

This can be much simpler, because pci_disable_msi() is always
available and is a NOP if the config option is off or MSI is not
enabled.  So you can just unconditionally do

	pci_disable_msi(pcidev);

 > +#ifdef NES_NAPI

I don't see anything that defines NES_NAPI.  I think for the final
merge we want a NAPI-only driver (ie no ifdef at all)... is there any
performance or other reason to ever build a non-NAPI driver (for a
modern kernel)?

OK, on a process level, my plan is to pull the current driver into a
"neteffect" branch in my git tree with the intention of merging it for
2.6.25.  I'll let you know when that's ready (probably early next
week).  I'll probably do some cleanups there, and you can send me
cleanup/fix patches against that branch any time too.  We should try
to keep the cycle time short: the interval between the first posting
of this driver and the current one was pretty long, and there's a lot
of cleanup to do to get ready for the next merge window.  Does that
plan make sense?

 - R.
