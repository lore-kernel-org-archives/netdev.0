From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: Proper pci_enable_device() error handling in resume routine
Date: Mon, 21 Aug 2006 11:12:03 -0700
Message-ID: <44E9F773.1070007@intel.com>
References: <20060820052922.GH20111@goober>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19337 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750897AbWHUSNl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 14:13:41 -0400
To: Valerie Henson <val_henson@linux.intel.com>
In-Reply-To: <20060820052922.GH20111@goober>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Valerie Henson wrote:
> I'm trying to properly handle pci_enable_device() errors in the resume
> routines of a couple of tulip drivers.  I noticed that several drivers
> pay attention to errors from pci_enable_device() in the init routine
> but ignore it on resume; other drivers vary wildly.  What's proper
> behavior when resuming?  Extant examples:
> 
> 0. Don't call pci_enable_device() at all (8139too)
> 1. Ignore the return value (eepro100, many others)
> 2. Check for failure and bail out, but return success (sungem)

Digging through e1000 I spot that we even pci_enable_device after a PCI error, 
so it is good practice I think to make sure the device is up. I suppose that 
most people can live without explicit re-enabling the device (most NICs are on 
anyway), but if we do enable it explicitly we should certainly check the result 
code. Interestingly enough we failed to do this in e1000, so I'll submit a 
patch for that later.

Cheers,

Auke
