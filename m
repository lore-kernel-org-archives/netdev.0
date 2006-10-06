From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] [TULIP] Fix section mismatch in de2104x.c
Date: Fri, 6 Oct 2006 11:03:17 -0700
Message-ID: <20061006110317.0c6c1f98@freekitty>
References: <11601583542790-git-send-email-matthew@wil.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Val Henson <val_henson@linux.intel.com>, netdev@vger.kernel.org,
	Helge Deller <deller@parisc-linux.org>,
	Kyle McMartin <kyle@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:22443 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932315AbWJFTFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2006 15:05:52 -0400
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <11601583542790-git-send-email-matthew@wil.cx>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 06 Oct 2006 12:12:34 -0600
Matthew Wilcox <matthew@wil.cx> wrote:

> From: Helge Deller <deller@parisc-linux.org>
> 
> WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to .init.text:de_init_one from .data.rel.local after 'de_driver' (at offset 0x20)
> WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to .exit.text:de_remove_one from .data.rel.local after 'de_driver' (at offset 0x28)

This is caused because with PCI hotplug the device might be probed after the init section
has been removed.  Ditto for remove.

The fix looks correct.

