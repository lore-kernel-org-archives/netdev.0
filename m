From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 2/2] net: ethernet: cpsw: fix interrupt lookup logic in
 cpsw_probe()
Date: Wed, 3 Sep 2014 13:52:49 +0530
Message-ID: <5406CFD9.6060706@ti.com>
References: <1409676245-13897-1-git-send-email-zonque@gmail.com> <1409676245-13897-2-git-send-email-zonque@gmail.com> <5406C336.3020005@ti.com> <5406C3A2.4060103@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <julia.lawall@lip6.fr>, <netdev@vger.kernel.org>,
	<george.cherian@ti.com>
To: Daniel Mack <daniel@zonque.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:58989 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751545AbaICIW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 04:22:57 -0400
In-Reply-To: <5406C3A2.4060103@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 03 September 2014 01:00 PM, Daniel Mack wrote:
> On 09/03/2014 09:28 AM, Mugunthan V N wrote:
>> On Tuesday 02 September 2014 10:14 PM, Daniel Mack wrote:
>>> The code in cpsw_probe() currently iterates over the available
>>> interrupt resources and requests each of them.  While doing so, it
>>> keeps track of their indices through priv->irqs_table.
>>>
>>> However, the code currently only remembers the last interrupt in
>>> a resource, and will leak the others if there is more than one.
>>> This can only happen for board-file driven platforms and not via DT,
>>> however.
>>>
>>> Also, there is currently no bounds check, while priv->irqs_table is a
>>> fixed-size array. If we are passed more than 4 resources, we're in
>>> trouble.
>>>
>>> This patch introduces a bounds check and changes the way interrupt
>>> indices are kept. Tested on a Beagle Bone Black board only.
>>>
>>> Signed-off-by: Daniel Mack <zonque@gmail.com>
>>
>> The drivers is not supported for non-DT platforms as all the platforms
>> which uses CPSW are DT only platforms.
> 
> Ok, thanks for explaining.
> 
> But then we can remove the iteration then and simplify the code, right?
> The bounds check should also be done.
> 

Right, we can simplify the code.

Regards
Mugunthan V N
