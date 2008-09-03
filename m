From: Zachary Amsden <zach@vmware.com>
Subject: RE: + e1000e-prevent-corruption-of-eeprom-nvm.patch added to
	-mmtree
Date: Wed, 03 Sep 2008 01:17:25 -0700
Message-ID: <1220429845.32688.182.camel@bodhitayantram.eng.vmware.com>
References: <200809021919.m82JJweC008488@imap1.linux-foundation.org>
	 <36D9DB17C6DE9E40B059440DB8D95F52060519D7@orsmsx418.amr.corp.intel.com>
	 <1220398304.32688.163.camel@bodhitayantram.eng.vmware.com>
	 <36D9DB17C6DE9E40B059440DB8D95F5206051BF7@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Qicheng Christopher Li <chrisl@vmware.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"arvidjaar@mail.ru" <arvidjaar@mail.ru>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Pratap Subrahmanyam <pratap@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:53507 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751140AbYICIS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 04:18:59 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5206051BF7@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-09-02 at 17:32 -0700, Brandeburg, Jesse wrote:
> Zachary Amsden wrote:
> >>> The EEPROM corruption is triggered by concurrent access of the
> >>> EEPROM read/write. Putting a lock around it solve the problem.
> >>>
> >> <snip>  I'd like to know how this actually solves a problem outside
> >> vmware.
> >
> > Yes.  This was observed on a physical E1000 device.
> 
> Hi Zach, thanks for the reply, can you give me a reproduction test so
> that we can verify this fix internally?  We are extremely interested.
> 
> <long explanation follows>

This was encountered by a customer and fixed by a developer who no
longer works for us.  We can't give any better explanation than - 

1) It looks like there is a massive catastrophic failure that causes
working hardware to DIE.

2) The E1000 driver is really crazily complicated and has to deal with
many different hardware versions, all with different idiosynchronicities
about this EEPROM locking, and it isn't really clear how the hardware
locking protects multiple racing kernel threads in all of these cases.

3) Casual inspection by several people who are not networking experts
shows several possibly viable paths where potential EEPROM corruption
might reasonably occur.

4) Adding locking around EEPROM read and write paths resulted in no more
problems by our customers.

5) It seems LKML customers are getting catastrophic failures where
EEPROMS are getting corrupted.

Thus, the obvious answer to me is ... LOCK AROUND EEPROM READS AND
WRITES now and figure out if there are deeper issues due to network
layer and E1000 complexities later, but ELIMINATE THE CATASTROPHIC
FAILURES ASAP.

> We are definitely investigating, please help us reproduce it if you can.

I'm sorry, we have no way to reproduce this, don't know anything about
the hardware the customer was using and really have almost zero context
on this bug because the developer who addressed the issue and fixed it
is long gone.  We only have statistical data showing 0% reproduction
since a very similar fix to the one you just NACKED.

I know it's not a very useful thing to say.

But seriously, if people's hardware is being hosed, you must take every
precaution in the world to stop it and worry about 'logical' arguments
regarding invariants in the network and driver layers later.

Zach

