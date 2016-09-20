From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH] net: netlink messages for HW addr programming
Date: Tue, 20 Sep 2016 07:49:59 +0200
Message-ID: <20160920054959.GB1843@nanopsycho.orion>
References: <1473958082-30982-1-git-send-email-pruddy@brocade.com>
 <57DEA9E2.3000703@cumulusnetworks.com>
 <1474296378.31262.59.camel@brocade.com>
 <57E0C9AF.4090406@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick Ruddy <pruddy@Brocade.com>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Luca Boccassi <lboccass@Brocade.com>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>,
        Sven-Thorsten Dietrich <sven@brocade.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36634 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753800AbcITFuC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 01:50:02 -0400
Received: by mail-wm0-f65.google.com with SMTP id b184so1420409wma.3
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 22:50:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57E0C9AF.4090406@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 20, 2016 at 07:31:27AM CEST, roopa@cumulusnetworks.com wrote:
>On 9/19/16, 7:46 AM, Patrick Ruddy wrote:
>> On Sun, 2016-09-18 at 07:51 -0700, Roopa Prabhu wrote:
>>> On 9/15/16, 9:48 AM, Patrick Ruddy wrote:
>>>> Add RTM_NEWADDR and RTM_DELADDR netlink messages with family
>>>> AF_UNSPEC to indicate interest in specific unicast and multicast
>>>> hardware addresses. These messages are sent when addresses are
>>>> added or deleted from the appropriate interface driver.
>>>> Added AF_UNSPEC GETADDR function to allow the netlink notifications
>>>> to be replayed to avoid loss of state due to application start
>>>> ordering or restart.
>>>>
>>>> Signed-off-by: Patrick Ruddy <pruddy@brocade.com>
>>>> ---
>>> RTM_NEWADDR and RTM_DELADDR are not used to add these entries to the kernel.
>>> so, it seems a bit wrong to use RTM_NEWADDR and RTM_DELADDR to notify them to
>>> userspace and also to request a special dump of these addresses.
>>>
>>> This could just be a new nested netlink attribute in the existing link dump ?
>> Hi Roopa
>>
>> Thanks for the review. I did initially code this using NEW/DEL/GET_LINK
>> messages but was asked to change to to ADDR messages by Stephen
>> Hemminger (cc'd). 
>>
>> However I agree that these addresses fall between the LINK and ADDR
>> areas so I'm happy to change this if we can reach some consensus on the
>> format.
>>
>ok, thanks for the history. yes, they do lie in a weird spot.

They are l2 addresses, they should be threated accordingly. Am I missing
something?


>the general convention for other rtnl registrations seems to be
>AF_UNSPEC family means include all supported families. thats where this seems a bit odd.
>
>On the other hand, one reason I see where using RTM_*ADDR will be useful for this is if we wanted
>to provide a way to add these uc and mc address via ip addr add in the future.
>ip addr add <lladdr> dev eth0
>
>Does this patch allow that in the future ?

This shoul go under ip link I believe. "ip addr" is for l3.


>
>also, will these l2 addresses now show up in 'ip addr show' output ?.
>
>thanks,
>Roopa
>
