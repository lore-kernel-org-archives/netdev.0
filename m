From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [patch 1/5][RFC] NET: Change pci_enable_device	topci_reenable_device
 to keep device enable balance
Date: Thu, 09 Aug 2007 13:49:20 -0700
Message-ID: <46BB7DD0.1000509@intel.com>
References: <20070802224423.GC5181@ifup.org> <78C9135A3D2ECE4B8162EBDCE82CAD7702035646@nekter> <20070809204552.GA6870@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	netdev@vger.kernel.org, teheo@suse.de,
	e1000-devel@lists.sourceforge.net
To: Brandon Philips <bphilips@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:5928 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753590AbXHIUtX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 16:49:23 -0400
In-Reply-To: <20070809204552.GA6870@ifup.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brandon Philips wrote:
> On 17:30 Wed 08 Aug 2007, Ramkrishna Vepa wrote:
>> Before slot_reset event is called io_error_detected could be called
>> (where pci_disable_device() is called), right? 
> 
> Oops!  Right, the documentation says .error_detected is _always_ called
> before .slot_reset.  So, this patch is not correct.  Please don't merge
> this.
> 
> From Documentation/pci-error-recovery.txt:
> 
> STEP 1: Notification
> --------------------
> Platform calls the error_detected() callback on every instance of
> every driver affected by the error.
> ...
> 
> If any driver requested a slot reset (by returning PCI_ERS_RESULT_NEED_RESET),
> then recovery proceeds to STEP 4 (Slot Reset).
> 
>> The pci_reenable_device() will call enable only if the device was
>> enabled before and would not be enabled if the device were disabled. Is
>> this the intended behavior?
> 
> Yes, you are right.  And no it isn't.


it would be great if you can convince Linas Vepstas to review and ack your patch 
- he's the one who knows the error handling code the best.

Auke
