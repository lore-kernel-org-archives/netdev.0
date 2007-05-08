From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Tue, 8 May 2007 08:35:19 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902CDF558@orsmsx414.amr.corp.intel.com>
References: <1178630917.4078.46.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhu, Yi" <yi.zhu@intel.com>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Patrick McHardy" <kaber@trash.net>, <netdev@vger.kernel.org>,
	<jgarzik@pobox.com>, "cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	<davem@davemloft.net>
To: <hadi@cyberus.ca>, "Johannes Berg" <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34614 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755477AbXEHPfc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 11:35:32 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1178630917.4078.46.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> As a summary, I am not against the concept of addressing 
> per-ring flow control. 
> Having said that, i fully understand where DaveM and Stephen 
> are coming from. Making such huge changes to a critical 
> region to support uncommon hardware doesnt abide to the 
> "optimize for the common" paradigm. 

But the point is that although the DCE spec inspired the development of
these patches, that is *not* the goal of these patches.  As Yi stated in
a previous reply to this thread, the ability for any hardware to control
its queues at the stack level in the kernel is something that is missing
in the kernel.  If the hardware doesn't want to support it, then the
patches as-is will not require anything to change in drivers to continue
working as they do today.

Bottom line: these patches are not for a specific technology.  I
presented that spec to show a possible use case for these patches.  Yi
presented a use case he can use in the wireless world.  I will be
posting another use case shortly using ATA over Ethernet.

> I dont believe wireless needs anything other than the simple 
> approach i described. The fact that there an occasional low 
> prio packet may endup going out first before a high prio due 
> to the contention is non-affecting to the overall results.

I don't see how we can agree that having any type of
head-of-line-blocking of a flow is or is not a problem.  You believe it
isn't an issue, but this is a gap that I see existing in the stack
today.  As networking is used for more advanced features (such as ndb or
VoIP), having the ability to separate flows from each other all the way
to the wire I see is a huge advantage to ensure true QoS.

It's a shift in thinking.

Thanks,
-PJ
