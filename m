From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 0/3] e1000,e1000e,igb: make ioport free for adapters that
 need NO ioport resources
Date: Sat, 21 Jun 2008 11:19:28 -0700
Message-ID: <485D4630.1090007@intel.com>
References: <485B1B8E.1060108@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>,
	auke-jan.h.kok@intel.com,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46036 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751730AbYFUSVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jun 2008 14:21:23 -0400
In-Reply-To: <485B1B8E.1060108@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taku Izumi wrote:
> Hi all,
> 
> Only a few Intel Gigabit Adapters need ioport resources for workaround,
> but most do not need them. Most adapters work properly without them.
> In the case where ioport resources are not assigned to adapters, this can
> happen on the large system, drivers' probe function fails like the following,
> and adapters can not be used as a result.
> 
>  e1000e 0002:22:00.0: device not available because of BAR 2 [0:1f] collisions
>  e1000e: probe of 0002:22:00.0 failed with error -22
> 
> These patches corrects behavior in probe function so as not to request ioport
> resources as long as they are not really needed. These are based on the
> ioport-free patch of e1000 driver from Auke Kok and Tomohiro Kusumi.
> 
> * [PATCH 1/3] e1000: make ioport free
> * [PATCH 2/3] e1000e: make ioport free
> * [PATCH 3/3] igb: make ioport free

I think patch 2 and 3 are way too large since igb and e1000e can be totally ioport
free at all times. There is no need to keep compatibility code for ioport in those
drivers as it's unlikely that this will ever be needed.

So, perhaps you can remove the ioport code from those 2 drivers (e1000e/igb)
completely and resubmit to Jeff Kirsher?

Cheers,

Auke
