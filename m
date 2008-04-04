From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [patch] NET: remove support for Davicom 9102 from the Tulip
	driver
Date: Fri, 4 Apr 2008 17:26:50 -0600
Message-ID: <20080404232650.GE27826@colo.lackof.org>
References: <Pine.SOC.4.64.0804031209540.2017@math.ut.ee> <47F69FBE.3020308@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cebbert@redhat.com, netdev@vger.kernel.org,
	Grant Grundler <grundler@parisc-linux.org>
To: Jeff Garzik <jeff@garzik.org>, Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:41769 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491AbYDDX1D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 19:27:03 -0400
Content-Disposition: inline
In-Reply-To: <47F69FBE.3020308@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 04, 2008 at 05:38:06PM -0400, Jeff Garzik wrote:
> Meelis Roos wrote:
>> CE> We have two reports that agree the tulip driver doesn't work for
>> CE> the Davicom 9102 (PCI id 1282:9102). The dmfe driver does work
>> CE> and also claims the same PCI ID.
>> NAK, dmfe does not work on some Sparc64 machines but tulip does.

jeff and davem already answered the basic SROM/MAC address issue.
Patches to fix this are associated with
	http://bugzilla.kernel.org/show_bug.cgi?id=9106

There is another "dmfe" issue reported in:
	http://bugzilla.kernel.org/show_bug.cgi?id=9094

But I think this one is related to something newer gcc versions (early
4.2 and current gcc-4.3. I've seen the same behavior with tulip driver
on parisc as described in bug #9094.


>> I happent to have a Sun Fire V100 with 2 Davicom NICs (1282:9102 (rev 
>> 31)).
>> tulip driver works for them, dmfe doesn't.

This experience doesn't agree with the bug report.
Meelis, can you please take a look at the bug report and add comments?

>> Tried with 2.6.25-rc7, first it
>> gets MAC addresses all zeroed and second, it only results in Tx timeouts.
>
> At the very least, it sounds like some SROM parsing problems on dmfe's part 
> -- assuming a standard SROM when sparc64 provides a more complicated one.
>
>
>> This issue was debugged somemonths ago on sparclinux mailing list. DaveM
>> fixed some bugs IIRC but it still does not work.
>
> URL to more info?

http://bugzilla.kernel.org/show_bug.cgi?id=9106

> Overall we need someone to either (a) work on tulip to get it working with 
> popular 9102's, or (b) work on dmfe to get it working on sparc64...  

We tried (b) but didn't get it working on V100 previously.
Several patches are attached to the bug report.


> Installers and users will continue to be confused by the present situation, 
> where the same PCI ID is claimed by two different drivers, and you just 
> sorta haveta "know" which one is right.

Agreed.  But I don't have consistent evidence that one is better than
the other. I'm open to reports of evidence for remove specific PCI IDs
from either driver.

thanks for adding me to the CC list.

grant
