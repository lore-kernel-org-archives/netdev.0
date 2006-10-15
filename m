From: David Brownell <david-b@pacbell.net>
Subject: Re: [Bulk] Re: [PATCH 1/2] [PCI] Check that MWI bit really did get
 set
Date: Sun, 15 Oct 2006 00:08:09 -0700
Message-ID: <20061015070809.978C714552@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
References: <1160161519800-git-send-email-matthew@wil.cx>
 <20061013214135.8fbc9f04.akpm@osdl.org>
 <20061014140249.GL11633@parisc-linux.org>
 <20061014134855.b66d7e65.akpm@osdl.org>
 <20061015032000.GP11633@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: val_henson@linux.intel.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org,
	gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp101.sbc.mail.mud.yahoo.com ([68.142.198.200]:25011 "HELO
	smtp101.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S964812AbWJOHIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Oct 2006 03:08:13 -0400
To: matthew@wil.cx, akpm@osdl.org
In-Reply-To: <20061015032000.GP11633@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> But the only effect of returning EINVAL is a printk (for this particular
> driver):
>
>         /* PCI Memory-Write-Invalidate cycle support is optional (uncommon) */
>         retval = pci_set_mwi(pdev);
>         if (!retval)
>                 ehci_dbg(ehci, "MWI active\n");

Erm, I've lost context here but it's completely legit for hardware
to NOT support MWI, so it is in no way an error if it's not set.
(Memory-Write-Invalidate is just a more efficient way to write data
that may be cached; if the device can't issue those cycles, there's
no loss of correctness.)

Since it's not an error, there should be no such printk ... which
is exactly how it's coded above.

Who is issuing the printk on a non-error code path??

- Dave


