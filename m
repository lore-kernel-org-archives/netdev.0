From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH v3 0/2] refactor code and mark expected switch
 fall-throughs
Date: Fri, 27 Oct 2017 14:48:53 -0500
Message-ID: <20171027144853.Horde.ExzHfROE4gaCiHalihXFClP@gator4166.hostgator.com>
References: <cover.1509080630.git.garsilva@embeddedor.com>
 <b0e6de21-b258-dc78-4710-a61b81ec419c@trinnet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Ralf Baechle <ralf@linux-mips.org>,
        walter harms <wharms@bfs.de>, Kevin Dawson <hal@kd.net.au>,
        "Bernard, f6bvp" <f6bvp@free.fr>,
        Thomas Osterried <thomas@osterried.de>
To: David Ranch <linux-hams@trinnet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway20.websitewelcome.com ([192.185.59.4]:15124 "EHLO
        gateway20.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751760AbdJ0UJ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 16:09:59 -0400
Received: from cm10.websitewelcome.com (cm10.websitewelcome.com [100.42.49.4])
        by gateway20.websitewelcome.com (Postfix) with ESMTP id 5505B400D34AC
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 14:48:54 -0500 (CDT)
In-Reply-To: <b0e6de21-b258-dc78-4710-a61b81ec419c@trinnet.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Quoting David Ranch <linux-hams@trinnet.net>:

> Hello Gustavo,
>
> I appreciate you working on keeping up the kernel and maintaining  
> some of the older feature areas like AX.25, Netrom, etc.  Other than  
> auditing your code changes, can you tell me what you're changing?  
> I've been attempting to find who / where does regression tests for  
> the Linus kernel to potentially ADD test suites for this area.  In  
> the recent past, we have seen a lot of toxicity creep into the  
> kernel because no one is testing their changes and backing out this  
> toxic code out of released Linux distributions takes a VERY long time.
>

Here you can see the patch I'm proposing to refactor some code:
https://patchwork.kernel.org/patch/10029119/

It does not add any new functionality. It's just a small function that  
helps to modularize and reduce the size of the code in the  
nr_add_node() function.

The function I'm proposing (re_sort_routes) re-sort the routes in  
quality order. It takes as arguments a pointer to the nr_node  
structure which contains the routes within and the indexes of the  
routes to re-sort.

This function also replaces a "manual" swap of the routes with a call  
to the swap macro.

Thanks
--
Gustavo A. R. Silva

> I'm willing to try and help here but I really would like to follow  
> some team's guidelines of how they would like tests to be created,  
> supported, etc.  Be it in VMs, containers, specific automation  
> languages, etc.
>
> --David
> KI6ZHD
>
>
>
>
> On 10/26/2017 10:50 PM, Gustavo A. R. Silva wrote:
>> The aim of this patchset is firstly to refactor code in nr_route.c  
>> in order to make it
>> easier to read and maintain and, secondly, to mark some expected  
>> switch fall-throughs
>> in preparation to enabling -Wimplicit-fallthrough.
>>
>> I have to mention that I did not implement any unit test.
>> If someone has any suggestions on how I could test this piece of code
>> it'd be greatly appreciated.
>>
>> Thanks
>>
>> Changes in v2:
>>  - Make use of the swap macro and remove inline keyword as suggested by
>>    Walter Harms and Kevin Dawson.
>>
>> Changes in v3:
>>  - Update subject for both patches.
>>  - Add this cover letter as suggested by David Miller.
>>
>> Gustavo A. R. Silva (2):
>>   net: netrom: nr_route: refactor code in nr_add_node
>>   net: netrom: nr_route: mark expected switch fall-throughs
>>
>>  net/netrom/nr_route.c | 62  
>> ++++++++++++++++-----------------------------------
>>  1 file changed, 19 insertions(+), 43 deletions(-)
>>
