From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware forwarded
 packets
Date: Fri, 20 Mar 2015 22:53:38 -0700
Message-ID: <550D0762.2090709@cumulusnetworks.com>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com> <550C54BC.4040509@intel.com> <CAE4R7bCC=VZerEfVRfn=NmQvE9bwQ-KGo7v77ghHOLAR5p5hwg@mail.gmail.com> <550C99DD.3090007@cumulusnetworks.com> <CAE4R7bBd8TeNCiXdOL9en-FfuTqqn==UYvAxHHD8BYHuFCiWBw@mail.gmail.com> <550CAD97.3000404@cumulusnetworks.com> <CAE4R7bDpsnqCjayXpsbhn-tYuuiiFuAgsZPufHCUh+KYSr+9mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35481 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbbCUFxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 01:53:41 -0400
Received: by pagj4 with SMTP id j4so39003522pag.2
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 22:53:40 -0700 (PDT)
In-Reply-To: <CAE4R7bDpsnqCjayXpsbhn-tYuuiiFuAgsZPufHCUh+KYSr+9mg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/20/15, 5:26 PM, Scott Feldman wrote:
> On Fri, Mar 20, 2015 at 4:30 PM, roopa <roopa@cumulusnetworks.com> wrote:
>> On 3/20/15, 3:37 PM, Scott Feldman wrote:
> [cut]
>>> I went back and read the thread just to remind me what the pros/cons
>>> where.  I think the mixed case isn't a concern since this
>>> BR_FLOOD_BCAST check is made on egress to the bridge port.  So only
>>> clear BR_FLOOD_BCAST on hw switch ports (if hw did the flood already
>>> amongst its ports), and leave it set for non-hw-ports.   It seems the
>>> patch should mostly be a clone of how BR_FLOOD is handled.  Is there
>>> more to it?
>> That may work.  But, we have recently moved igmp handling to software in
>> kernel and i was trying to make this work for that case. I am going to try what you
>> suggest  by finding a work around for the igmp case.
> Wait, you lost me on the IGMP comment...that wasn't in your commit
> msg.  Do you mean IGMP snooping?  What are you trying to get to work?
scott, I brought up igmp as an example because we do some selective 
forwarding there.
The point i was trying to make is disabling forwarding on ports is not 
good enough. In some cases, we
do end up making decisions in the switch driver if the packet should be 
forwarded.
  And, that's the reason why having a way to indicate this per packet is 
more flexible.
>
> It's hard to understand the pieces you're considering without example
> implementations.
agreed.

> Can you use rocker or DSA to show example?
yep, let me see what i can do.
I don't plan to add it as a bridge port flag right away,  because 
thinking through this again,
we might hit something else down the lane and we might end up piling up 
flags.
lets see as more use-cases pop up.
