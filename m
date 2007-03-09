From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/3] e1000: FIX: be ready for incoming irq at pci_request_irq
Date: Fri, 09 Mar 2007 09:11:41 -0800
Message-ID: <45F1954D.4000506@intel.com>
References: <20070306165721.27434.23796.stgit@localhost.localdomain> <45F18F7C.3030801@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, john.ronciak@intel.com,
	jesse.brandeburg@intel.com,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5704 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767403AbXCIRMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 12:12:17 -0500
In-Reply-To: <45F18F7C.3030801@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Auke Kok wrote:
>> From: Auke Kok <auke-jan.h.kok@intel.com>
>>
>> DEBUG_SHIRQ code exposed that e1000 was not ready for incoming interrupts
>> after having called pci_request_irq. This obviously requires us to finish
>> our software setup which assigns the irq handler before we request the
>> irq.
>>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> ---
>>
>>  drivers/net/e1000/e1000_main.c |   66 +++++++++++++++++++++++++++-------------
>>  1 files changed, 45 insertions(+), 21 deletions(-)
> 
> All these do indeed look like fixes to me.  But they look like low 
> priority fixes that would need some public testing behind them, and it's 
> pretty late in the 2.6.21-rc game.
> 
> I'll merge them into an e1000-fixes branch for now (and propagates 
> through #ALL to akpm's -mm).  If replies to this email indicate we 
> really should push these upstream for 2.6.21-rc, it will be easy enough 
> to do so via #e1000-fixes.

Personally, I think this is really really needed. I'm surprised that you already 
didn't push this considering Andrew pulled this into -mm immediately.

We've also been crunching this patch in our labs for a whole week now doing all 
sorts of load/unload up/down torture and it's a real improvement. Especially 
ESB2 systems were hit with this bug irregardless of the DEBUG_SHIRQ code active 
or not, so it's a real bug with real fix.

but hey, it doesn't fix a new problem :)

Auke



