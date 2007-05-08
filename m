From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Tue, 08 May 2007 19:28:22 -0400
Message-ID: <1178666902.4055.28.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902CDF558@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"Zhu, Yi" <yi.zhu@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com, cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:9225 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967800AbXEHX22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 19:28:28 -0400
Received: by wx-out-0506.google.com with SMTP id h31so7032wxd
        for <netdev@vger.kernel.org>; Tue, 08 May 2007 16:28:28 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902CDF558@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-08-05 at 08:35 -0700, Waskiewicz Jr, Peter P wrote:

> But the point is that although the DCE spec inspired the development of
> these patches, that is *not* the goal of these patches.  As Yi stated in
> a previous reply to this thread, the ability for any hardware to control
> its queues at the stack level in the kernel is something that is missing
> in the kernel.  If the hardware doesn't want to support it, then the
> patches as-is will not require anything to change in drivers to continue
> working as they do today.

Wireless offers a strict priority scheduler with statistical transmit
(as opposed to deterministic offered by the linux strict prio qdisc);
so wireless is not in the same boat as DCE.

> Bottom line: these patches are not for a specific technology.  I
> presented that spec to show a possible use case for these patches.  Yi
> presented a use case he can use in the wireless world.  I will be
> posting another use case shortly using ATA over Ethernet.
> 

Once you run the ATA over ethernet with your approach, please repeat the
test with a single ring in hardware and an equivalent qdisc in linux.
I dont believe you will see any difference - Linux is that good.
This is not to say i am against your patches, I am just for optimizing
for the common.

> > I dont believe wireless needs anything other than the simple 
> > approach i described. The fact that there an occasional low 
> > prio packet may endup going out first before a high prio due 
> > to the contention is non-affecting to the overall results.
> 
> I don't see how we can agree that having any type of
> head-of-line-blocking of a flow is or is not a problem.  

But where is this head-of-line blocking coming from?
Please correct me if am wrong:
If i had 4 hardware rings/queues in a wireless NIC with 4 different
WMM priorities all filled up (I would say impposible to achieve but for
the sake of discussion assume possible), then 
there is still a probability that a low prio packet will be sent first
before a high prio one. It all depends on the probabilistic nature of
the channel availability as well as the tx opportunity and backoff
timings.

> You believe it
> isn't an issue, but this is a gap that I see existing in the stack
> today.  As networking is used for more advanced features (such as ndb or
> VoIP), having the ability to separate flows from each other all the way
> to the wire I see is a huge advantage to ensure true QoS.
> 

You dont believe Linux has actually been doing QoS all these years
before DCE? It has. And we have been separating flows all those years
too. 
Wireless with CSMA/CA is a slightly different beast due to the shared
channels; its worse but not very different in nature than the case where
you have a shared ethernet hub (CSMA/CD) and you keep adding hosts to it
- we dont ask the qdiscs to backoff because we have a collision.
Where i find wireless intriguing is in the case where its available
bandwidth adjusts given the signal strength - but you are talking about
HOLs not that specific phenomena.

cheers,
jamal


