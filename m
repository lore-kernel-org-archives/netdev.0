From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] switchdev: call bridge setlink/dellink ndos
 recursively
Date: Mon, 16 Mar 2015 18:37:27 +0100
Message-ID: <20150316173727.GK2058@nanopsycho.orion>
References: <1426515774-21038-1-git-send-email-jiri@resnulli.us>
 <5506F4DF.30700@cumulusnetworks.com>
 <20150316163638.GI2058@nanopsycho.orion>
 <55070DB6.7020504@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, sfeldma@gmail.com
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:35880 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754638AbbCPRhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 13:37:31 -0400
Received: by wgra20 with SMTP id a20so45992494wgr.3
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 10:37:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55070DB6.7020504@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 16, 2015 at 06:07:02PM CET, roopa@cumulusnetworks.com wrote:
>On 3/16/15, 9:36 AM, Jiri Pirko wrote:
>>Mon, Mar 16, 2015 at 04:21:03PM CET, roopa@cumulusnetworks.com wrote:
>>>On 3/16/15, 7:22 AM, Jiri Pirko wrote:
>>>>There has been a discussion about if it's better to let masters to
>>>>propagate call down themself or if its better just blindly go down and
>>>>try to call ndo on every lower netdev. Turned out that more people (me
>>>>not included) like the second option better.
>>>>
>>>>This patch changes bridge setlink/dellink in that direction.
>>>>Sorry Roopa for forcing you to do it the way I liked initially.
>>>>
>>>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>>no worries. thanks for submitting the patch Jiri.
>>>
>>>One thing though (Which i also mentioned in one of the threads on this),
>>>the below command will not work with layered devices with the below patch.
>>>Because 'self' commands will directly try to find the switch port driver from
>>>rtnetlink.c and they dont use the switch dev api.
>>>
>>>bridge link set dev bond0 learning off self
>>>
>>>
>>>The code that currently exists in the tree with bond and team supporting the
>>>op
>>>will actually work.
>>Hmm, interesting.
>>
>>DaveM, this might be a good argument for call propagation. What do you
>>think?
>>
>For the stp api, it is not...because stp is run in the bridge driver and
>always involves the switchdev api.
>
>lets hold on to in-tree getlink/setlink before we find a better way.

Okay. Makes sense.

>
>my 2c
