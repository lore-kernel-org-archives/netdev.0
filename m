From: Andi Kleen <ak@linux.intel.com>
Subject: Re: hardware time stamps + existing time stamp usage
Date: Tue, 21 Oct 2008 09:04:21 +0200
Message-ID: <48FD7EF5.6050805@linux.intel.com>
References: <1224253423.17450.211.camel@ecld0pohly> <200810182237.02373.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick Ohly <patrick.ohly@intel.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:55766 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751015AbYJUHEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 03:04:11 -0400
In-Reply-To: <200810182237.02373.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> We can even compute the delta periodically now, to maintain better system - 
> hardware timestamps synchronization, as we can keep and multiple deltas (each 
> one associated with a modulo number).

The problem with this scheme is that it's unlikely to be precise enough to guarantee
monoticity (that is that your delta clock compared to the system clock never goes
backwards). And that tends to be a common requirements in system time stamps.
Not having that would risk breaking existing applications.

My recommendation would be to find some way to use a separate field and also
use a separate API. That would also allow you to extend it (e.g. pass down
the interface number), so that different time stamps from different interfaces
are supported.

-Andi
