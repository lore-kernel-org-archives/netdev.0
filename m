From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/3] e1000: fix shared interrupt warning message
Date: Sat, 17 Feb 2007 12:47:57 -0800
Message-ID: <45D769FD.4030508@intel.com>
References: <20070216223913.26963.76602.stgit@gitlost.site> <20070216223926.26963.52634.stgit@gitlost.site> <45D767C8.3040508@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2547 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932444AbXBQUsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 15:48:00 -0500
In-Reply-To: <45D767C8.3040508@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> ---
>>
>>  drivers/net/e1000/e1000_main.c |   12 ++++++------
>>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> applied 1-3, though patch #1 had a noticable lack of description.  you 
> should describe your change, not just the condition that prompted it. 
> operation reordering is something that people shouldn't have to /try/ to 
> understand.  Things should just be obvious, and if not, document why.

For the record then:

It is suspected that workarounds in the _up() routine of e1000 can cause the 
receive unit to be enabled before we're all done initializing the adapter data. 
An interrupt arriving before we're all done setting up obviously causes 
problems. To fix, we postpone enabling interrupts completely until the software 
intialization is finished.

Thanks,

Auke
