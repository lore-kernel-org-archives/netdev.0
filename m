From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next] switchdev: call bridge setlink/dellink ndos
 recursively
Date: Mon, 16 Mar 2015 10:07:02 -0700
Message-ID: <55070DB6.7020504@cumulusnetworks.com>
References: <1426515774-21038-1-git-send-email-jiri@resnulli.us> <5506F4DF.30700@cumulusnetworks.com> <20150316163638.GI2058@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, sfeldma@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36123 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932499AbbCPRHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 13:07:04 -0400
Received: by padcy3 with SMTP id cy3so70163344pad.3
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 10:07:04 -0700 (PDT)
In-Reply-To: <20150316163638.GI2058@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/16/15, 9:36 AM, Jiri Pirko wrote:
> Mon, Mar 16, 2015 at 04:21:03PM CET, roopa@cumulusnetworks.com wrote:
>> On 3/16/15, 7:22 AM, Jiri Pirko wrote:
>>> There has been a discussion about if it's better to let masters to
>>> propagate call down themself or if its better just blindly go down and
>>> try to call ndo on every lower netdev. Turned out that more people (me
>>> not included) like the second option better.
>>>
>>> This patch changes bridge setlink/dellink in that direction.
>>> Sorry Roopa for forcing you to do it the way I liked initially.
>>>
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> no worries. thanks for submitting the patch Jiri.
>>
>> One thing though (Which i also mentioned in one of the threads on this),
>> the below command will not work with layered devices with the below patch.
>> Because 'self' commands will directly try to find the switch port driver from
>> rtnetlink.c and they dont use the switch dev api.
>>
>> bridge link set dev bond0 learning off self
>>
>>
>> The code that currently exists in the tree with bond and team supporting the
>> op
>> will actually work.
> Hmm, interesting.
>
> DaveM, this might be a good argument for call propagation. What do you
> think?
>
For the stp api, it is not...because stp is run in the bridge driver and 
always involves the switchdev api.

lets hold on to in-tree getlink/setlink before we find a better way.

my 2c
