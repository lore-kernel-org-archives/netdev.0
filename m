From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/3] e1000: fix shared interrupt warning message
Date: Sat, 17 Feb 2007 18:20:33 -0800
Message-ID: <45D7B7F1.8020504@intel.com>
References: <20070216223913.26963.76602.stgit@gitlost.site> <20070216223926.26963.52634.stgit@gitlost.site> <45D767C8.3040508@garzik.org> <45D769FD.4030508@intel.com> <20070217231949.GB17396@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:1999 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993153AbXBRCUf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 21:20:35 -0500
In-Reply-To: <20070217231949.GB17396@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Auke Kok <auke-jan.h.kok@intel.com> :
> [...]
>> It is suspected that workarounds in the _up() routine of e1000 can cause 
>         ^^^^^^^^^
>> the receive unit to be enabled before we're all done initializing the 
>> adapter data. An interrupt arriving before we're all done setting up 
>> obviously causes problems. To fix, we postpone enabling interrupts 
>> completely until the software intialization is finished.
> 
> Call me dense but is there a chance that the same receive unit that should
> not be enabled now emits interrupts between e1000_up() and request_irq() ?

turning on the receive unit starts the rx logic on the mac, but doesn't make the 
mac generate interrupts as far as I know. The fix was verified and even 
suggested earlier by some people as well.

Cheers,

Auke
