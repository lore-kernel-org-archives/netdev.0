From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next] switchdev: call bridge setlink/dellink ndos
 recursively
Date: Mon, 16 Mar 2015 08:21:03 -0700
Message-ID: <5506F4DF.30700@cumulusnetworks.com>
References: <1426515774-21038-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, sfeldma@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34369 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756325AbbCPPVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 11:21:06 -0400
Received: by pacwe9 with SMTP id we9so67692622pac.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 08:21:06 -0700 (PDT)
In-Reply-To: <1426515774-21038-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/16/15, 7:22 AM, Jiri Pirko wrote:
> There has been a discussion about if it's better to let masters to
> propagate call down themself or if its better just blindly go down and
> try to call ndo on every lower netdev. Turned out that more people (me
> not included) like the second option better.
>
> This patch changes bridge setlink/dellink in that direction.
> Sorry Roopa for forcing you to do it the way I liked initially.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

no worries. thanks for submitting the patch Jiri.

One thing though (Which i also mentioned in one of the threads on this),
the below command will not work with layered devices with the below patch.
Because 'self' commands will directly try to find the switch port driver 
from
rtnetlink.c and they dont use the switch dev api.

bridge link set dev bond0 learning off self


The code that currently exists in the tree with bond and team supporting 
the op
will actually work.

If you agree with the above, I can rethink how this can be made to work 
with the 'self'
indirection from rtnetlink.c and still use transparent lowerdev 
traversal and resubmit.
Or if you prefer to resubmit, you can.

Thanks,
Roopa
