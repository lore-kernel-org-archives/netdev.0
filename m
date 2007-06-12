From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 19:38:30 -0400
Message-ID: <1181691511.4085.84.camel@localhost>
References: <D0122E209EBF8D4CAB38EC6A8AF244E502AB31CF@hasmsx412.ger.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Cohen, Guy" <guy.cohen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:4859 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755226AbXFLXie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 19:38:34 -0400
Received: by py-out-1112.google.com with SMTP id a29so32904pyi
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2007 16:38:34 -0700 (PDT)
In-Reply-To: <D0122E209EBF8D4CAB38EC6A8AF244E502AB31CF@hasmsx412.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guy,

On Tue, 2007-12-06 at 17:04 +0300, Cohen, Guy wrote:
> Hi Jamal,
> 
> Here is a simple scenario (nothing here is rare of extreme case):
> - Busy wireless environment
> - FTP TX on BE queue (low priority)
> - Skype TX on VO queue (high priority)
> 
> The channel is busy with high priority packets hence the BE packets are
> transmitted to the air rarely so the DMA/HW queue of the BE access
> category gets full and the qdisc is stopped.
> Now periodic VO-tagged Skype packets arrive. I would expect that they
> get the priority (and pass) in all stages of the stack and reach the HW
> ASAP and compete there on the medium with the other access categories
> and the other clients on the channel.
> Now this packet will be stuck in the qdisc and wait there until a BE
> packet is transmitted, which can take a long time. This is a real
> problem.

Understood.
My take is that this is resolvable by understanding the nature of the
beast. IOW, the strategy of when to open up on such a medium is not
conventional as one of a wired netdev. 
You can use signalling from the media such as an AP giving you 
signals for different ACs to open up; example: if the AC_BE is not being
allowed out and it is just rotting because the AP is favoring VO, then
you need to occasionally open up the tx path for the driver etc.

> There is also a problem with the queues that will be dedicated to TX
> aggregation in 11n (currently implemented) - the packets will be
> classified to queues by the destination MAC address and not only by the
> priority class, but I don't want to get into that now. 

We have an infrastructure at the qdisc level for selecting queues based
on literally anything you can think of in a packet as well as metadata.
So i think this aspect should be fine.

> I think that
> there are enough arguments now why the patch that started this thread is
> needed...

Sorry Guy, I dont see it that way - unfortunately i dont think anybody
else other than Patrick understood what i said  and this thread is going
on for too long i doubt 99% of the people are following any more ;->

> In most scenarios BK packets will be transmitted and will win the medium
> against VO packets (thought, in some non-favored ratio).

So if understand you correctly: over a period of time, yes BK will make
it out but under contention it will loose; is that always? Is there some
mathematics behind this stuff?

> Sorry, I'm really overloaded - I won't be able to review the docs you
> sent (really apologize for that).

No problem. I totaly understand.

> The WMM parameters of the AC are set and controlled by the network/BSS
> (access point) administrator and can be used in anyway. There are the
> default parameters but they can be changed.

It would certainly lead to unexpected behavior if you start favoring BE
over VO, no? Would that ever happen by adjusting the WMM parameters?

cheers,
jamal



