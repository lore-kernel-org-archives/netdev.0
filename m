From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: hardware time stamps + existing time stamp usage
Date: Tue, 21 Oct 2008 09:40:39 +0200
Message-ID: <1224574839.17450.332.camel@ecld0pohly>
References: <1224253423.17450.211.camel@ecld0pohly>
	 <200810182237.02373.opurdila@ixiacom.com>
	 <48FD7EF5.6050805@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Andi Kleen <ak@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26805 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751412AbYJUHmv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 03:42:51 -0400
In-Reply-To: <48FD7EF5.6050805@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-10-21 at 01:04 -0600, Andi Kleen wrote:
> > We can even compute the delta periodically now, to maintain better system -
> > hardware timestamps synchronization, as we can keep and multiple deltas (each
> > one associated with a modulo number).
> 
> The problem with this scheme is that it's unlikely to be precise enough to guarantee
> monoticity (that is that your delta clock compared to the system clock never goes
> backwards). And that tends to be a common requirements in system time stamps.
> Not having that would risk breaking existing applications.

Agreed. But even those users who need absolute monoticity would be able
to use PTP: at least the Intel hardware would be configured to only time
stamp PTP packets while the application packets that the user cares
about are still time stamped in software, as before.

> My recommendation would be to find some way to use a separate field and also
> use a separate API. That would also allow you to extend it (e.g. pass down
> the interface number), so that different time stamps from different interfaces
> are supported.

The latest proposal already uses such a separate API for HW time stamps,
so we are fine in that regard. In my opinion the API should only return
information which isn't available otherwise (currently the original HW
time stamp); the interface number should be returned with the existing
IP_PKTINFO.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

