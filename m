From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] IPV4: remove addresses and routes when carrier is
 lost
Date: Tue, 03 Jun 2008 18:44:44 +0200
Message-ID: <484574FC.5050004@trash.net>
References: <20080602165249.52a467dc@extreme>	<20080603150524.GA16165@csclub.uwaterloo.ca>	<20080603085707.51fdabbb@speedy>	<48456B62.8050909@trash.net> <20080603093159.36070e73@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45615 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbYFCQoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 12:44:46 -0400
In-Reply-To: <20080603093159.36070e73@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 03 Jun 2008 18:03:46 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> Stephen Hemminger wrote:
>>> On Tue, 3 Jun 2008 11:05:24 -0400
>>> lsorense@csclub.uwaterloo.ca (Lennart Sorensen) wrote:
>>>
>>>> On Mon, Jun 02, 2008 at 04:52:49PM -0700, Stephen Hemminger wrote:
>>>>> This patch adds a new configuration sysctl that causes link loss to clear
>>>>> FIB state in the same way as admin down. This allows for routing daemons
>>>>> like Quagga which have option to remove routes when carrier is lost.
>>>>>
>>>>> This has been a long standing problem with Quagga on Linux with complaints
>>>>> on the developers list going back to 2004. Fixing it properly, so the routing 
>>>>> daemon manages the RIB, and the kernel manages the FIB, requires changes to
>>>>> both parts.
>>>> Does this cover only the local route for the interface, or all routes
>>>> assigned staticly to the interface too?
>>> The patch makes carrier down == interface down. So the same
>>> behaviour as doing 'ip link set dev eth3 down'
>>
>> Can't the routing daemon simply ignore routes with a
>> device that has no carrier?
>>
> 
> It does that, but the problem is that packets get routed in kernel
> to interfaces without carrier, rather than being correctly rerouted
> over alternate paths.

I see, thanks for the explanation.
