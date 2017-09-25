From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 03/12] ipmr: Add FIB notification access
 functions
Date: Mon, 25 Sep 2017 12:59:07 +0300
Message-ID: <9360a6b5-c7e6-ec77-5efd-5dfc0a1a7848@cumulusnetworks.com>
References: <20170924172212.10096-1-jiri@resnulli.us>
 <20170924172212.10096-4-jiri@resnulli.us>
 <4c09e09c-d184-0d69-110d-a3d5ba721564@cumulusnetworks.com>
 <bcf097e3-9c6c-b4bd-ac1e-8675ae87510e@cumulusnetworks.com>
 <20170925094713.GD1899@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com, andrew@lunn.ch
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:45551 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751408AbdIYJ7K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 05:59:10 -0400
Received: by mail-wm0-f48.google.com with SMTP id q124so17692572wmb.0
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 02:59:10 -0700 (PDT)
In-Reply-To: <20170925094713.GD1899@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/09/17 12:47, Jiri Pirko wrote:
> Mon, Sep 25, 2017 at 11:40:16AM CEST, nikolay@cumulusnetworks.com wrote:
>> On 25/09/17 12:35, Nikolay Aleksandrov wrote:
>>> On 24/09/17 20:22, Jiri Pirko wrote:
>>>> From: Yotam Gigi <yotamg@mellanox.com>
>>>>
>>>> Make the ipmr module register as a FIB notifier. To do that, implement both
>>>> the ipmr_seq_read and ipmr_dump ops.
>>>>
>>>> The ipmr_seq_read op returns a sequence counter that is incremented on
>>>> every notification related operation done by the ipmr. To implement that,
>>>> add a sequence counter in the netns_ipv4 struct and increment it whenever a
>>>> new MFC route or VIF are added or deleted. The sequence operations are
>>>> protected by the RTNL lock.
>>>>
>>>> The ipmr_dump iterates the list of MFC routes and the list of VIF entries
>>>> and sends notifications about them. The entries dump is done under RCU
>>>> where the VIF dump uses the mrt_lock too, as the vif->dev field can change
>>>> under RCU.
>>>>
>>>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>>>> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
>>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>>> ---
>>>> v1->v2:
>>>>  - Take the mrt_lock when dumping VIF entries.
>>>> ---
>>>>  include/linux/mroute.h   |  15 ++++++
>>>>  include/net/netns/ipv4.h |   3 ++
>>>>  net/ipv4/ipmr.c          | 137 ++++++++++++++++++++++++++++++++++++++++++++++-
>>>>  3 files changed, 153 insertions(+), 2 deletions(-)
>>>>
>>>
>>> LGTM,
>>>
>>> Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>
>>>
>>
>> One note here if you're going to spin another version of the set, you can
>> consider renaming the call_* functions to either mroute_* or ipmr_* (e.g.
>> ipmr_call_...). I personally prefer the ipmr prefix.
> 
> The naming scheme in this patch is aligned with the rest of the code.

Definitely not aligned with the rest of the ipmr code because it does not
have such calls. Its notifications have a prefix which is not call_.

> Please see "call_netdevice_notifiers" for example.

Sure, I don't care that much which style you choose, that's why I wrote
_consider_, since this code is contained within ipmr and is not exported
anywhere.

> Please feel free to send a patch to chanche them all.
> 

Jumping the gun a little bit here. :-)
