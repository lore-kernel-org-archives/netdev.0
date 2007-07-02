From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI	Express adapters...
Date: Mon, 02 Jul 2007 15:02:57 -0700
Message-ID: <46897611.9020207@intel.com>
References: <4688F512.3030801@garzik.org> <E35F4F4D7F6C9E4E826FEC1F86CEF58304193063@orsmsx412.amr.corp.intel.com> <20070702140958.5ea6571a@freepuppy.localdomain.hemminger.net> <20070702214238.GA7085@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	arjan@linux.intel.com, akpm@linux-foundation.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47813 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755872AbXGBWDB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 18:03:01 -0400
In-Reply-To: <20070702214238.GA7085@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> On Mon, Jul 02, 2007 at 02:09:58PM -0700, Stephen Hemminger wrote:
>> The patch is close to ready for 2.6.24 when this driver will need to show up.
> 
> If intel manages to fix up the reamining issues I'd rather see it appear
> in 2.6.23..
> 
>> Since I know Intel will be forced to backport this to older distro's. You
>> would be best to have a single receive queue version when you have to make
>> it work on the older code.
> 
> But that'll require the single receiver queue version I guess.  The
> netdevice abuse is the only really major issue I see, although I'd of
> course really like to see the driver getting rid of the bitfield abuse
> aswell.

well, FWIW when I started looking at adding these flags I looked in various 
subsystems in the kernel and picked an implementation that suited. Guess what 
pci.h has? ...:

	unsigned int msi_enabled:1;
	unsigned int msix_enabled:1;

this is literally where I copied the example from

I suppose I can fix those, but I really don't understand what all the fuzz is 
about here. We're only conserving memory and staying far away from the real 
risks of bitmasks, so forgive me if I don't grasp the problem.

Honestly, if this is really considered "Bad coding" (TM) then we need to fix 
these prominent abuses of it too.

I count about 60 or so of these bitfields in drivers/net... (and countless more 
in other parts) !

Auke
