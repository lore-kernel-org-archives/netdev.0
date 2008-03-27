From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH] e1000e: test MSI interrupts
Date: Thu, 27 Mar 2008 10:53:43 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5204BF07F7@orsmsx418.amr.corp.intel.com>
References: <20080326183631.25114.90265.stgit@localhost.localdomain> <47EA9911.8040101@garzik.org> <47EAB54A.1060306@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>
To: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38280 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183AbYC0R4k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 13:56:40 -0400
Content-class: urn:content-classes:message
In-Reply-To: <47EAB54A.1060306@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:
> Jeff Garzik wrote:
>> Auke Kok wrote:
>>> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>> 
>>> Test the MSI interrupt physically once before assuming that it
>>> actually works. Several platforms have already come across that
>>> have non-functional MSI interrupts and this code will attempt
>>> to detect those safely. Once the test succeeds MSI interrupts
>>> will be enabled.
>>> 
>>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

>> Ah, the perennial add-same-test-to-every-driver conundrum.
>> 
>> I think we are far enough along with MSI to _not_ do this anymore in
>> drivers. 

Actually, I'm hoping you'll allow this Jeff, we have a production system
(see below) we know about that doesn't like the way 82571 formats MSI
interrupt messages.  All other systems seem to be okay with this format
of MSI messages, but this system implemented a stricter interpretation
of the spec, and so even though that system doesn't need a quirk for MSI
because MSI works in general, we still MUST test the MSI vector to make
sure it works *for us*  In this case it comes down to being an errata
workaround.

Since there is no way to "test" generation of an interrupt from any
specific hardware device without internal knowledge of said device,
there isn't a way for us to help the kernel by writing a generic "test
MSI" routine.

I would prefer this "generic test" code be in the driver rather than
having to identify all the chipsets that fail and have the driver do
*specific chipset* detection ala bnx2.c's 8132 bridge workaround.

>> The platforms with MSI problems should be discovered, made public,
>> and worked around. 

This is our workaround, it is our fault, the incompatible chipset is in
an x3850 IBM system.

>> Otherwise you hide the same problem, just for someone else to
>> discover with another component of the machine.

We had avoided this test in the past based on your recommendation but in
this case I don't see a way around it, do you?  I'm open to other
suggestions but we need to solve the problem somehow in an *automated*
way.  IBM requested we do it this way.
 
Jesse
