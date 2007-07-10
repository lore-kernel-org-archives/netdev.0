From: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Subject: RE: [PATCH 0/1] ixgbe: Support for Intel(R) 10GbE PCI Express adapters -	Take #2
Date: Tue, 10 Jul 2007 11:11:44 -0700
Message-ID: <E35F4F4D7F6C9E4E826FEC1F86CEF583042488B2@orsmsx412.amr.corp.intel.com>
References: <4693C951.3040608@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <arjan@linux.intel.com>,
	<akpm@linux-foundation.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hch@infradead.org>,
	<shemminger@linux-foundation.org>, <nhorman@tuxdriver.com>,
	<inaky@linux.intel.com>, <mb@bu3sch.de>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43849 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759201AbXGJSLr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 14:11:47 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4693C951.3040608@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/10/07, Jeff Garzik <jeff@garzik.org> wrote:
> Ayyappan.Veeraiyan@intel.com wrote:
> 
> Doing both tends to signal that the author hasn't bothered to measure
> the differences between various approaches, and pick a clear winner.
> 

I did pick NAPI in our previous submission based on various tests. But
to get 10Gig line rate we need to use multiple Rx queues which will need
fake netdevs.. Since fake netdevs weren't acceptable, I added non-NAPI
support which gets 10Gig line rate with multi-rx. I am ok with removing
NAPI support till the work of separating the netdevs and NAPI work is
done..

> I strongly prefer NAPI combined with hardware interrupt mitigation --
it
> helps with multiple net interfaces balance load across the system, at
> times of high load -- but I'm open to other solutions as well.
> 

Majority of tests we did here, we saw NAPI is better. But for some
specific test cases (especially if we add the SW RSC i.e. LRO), we saw
better throughput and CPU utilization with non-NAPI.

> So...  what are your preferences?  What is the setup that gets closest
> to wire speed under Linux?  :)

With SW LRO, non-NAPI is better but without LRO, NAPI is better but NAPI
needs multiple Rx queues. So given the limitations, non-NPAI is my
preference now.

I will post the performance numbers later today..

> 
>         Jeff

Thanks..

Ayyappan
