From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 03/12] ipmr: Add FIB notification access
 functions
Date: Mon, 25 Sep 2017 11:47:13 +0200
Message-ID: <20170925094713.GD1899@nanopsycho>
References: <20170924172212.10096-1-jiri@resnulli.us>
 <20170924172212.10096-4-jiri@resnulli.us>
 <4c09e09c-d184-0d69-110d-a3d5ba721564@cumulusnetworks.com>
 <bcf097e3-9c6c-b4bd-ac1e-8675ae87510e@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com, andrew@lunn.ch
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:38459 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751880AbdIYJrP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 05:47:15 -0400
Received: by mail-wr0-f196.google.com with SMTP id p37so1637852wrb.5
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 02:47:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <bcf097e3-9c6c-b4bd-ac1e-8675ae87510e@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 25, 2017 at 11:40:16AM CEST, nikolay@cumulusnetworks.com wrote:
>On 25/09/17 12:35, Nikolay Aleksandrov wrote:
>> On 24/09/17 20:22, Jiri Pirko wrote:
>>> From: Yotam Gigi <yotamg@mellanox.com>
>>>
>>> Make the ipmr module register as a FIB notifier. To do that, implement both
>>> the ipmr_seq_read and ipmr_dump ops.
>>>
>>> The ipmr_seq_read op returns a sequence counter that is incremented on
>>> every notification related operation done by the ipmr. To implement that,
>>> add a sequence counter in the netns_ipv4 struct and increment it whenever a
>>> new MFC route or VIF are added or deleted. The sequence operations are
>>> protected by the RTNL lock.
>>>
>>> The ipmr_dump iterates the list of MFC routes and the list of VIF entries
>>> and sends notifications about them. The entries dump is done under RCU
>>> where the VIF dump uses the mrt_lock too, as the vif->dev field can change
>>> under RCU.
>>>
>>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>>> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>> ---
>>> v1->v2:
>>>  - Take the mrt_lock when dumping VIF entries.
>>> ---
>>>  include/linux/mroute.h   |  15 ++++++
>>>  include/net/netns/ipv4.h |   3 ++
>>>  net/ipv4/ipmr.c          | 137 ++++++++++++++++++++++++++++++++++++++++++++++-
>>>  3 files changed, 153 insertions(+), 2 deletions(-)
>>>
>> 
>> LGTM,
>> 
>> Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> 
>> 
>
>One note here if you're going to spin another version of the set, you can
>consider renaming the call_* functions to either mroute_* or ipmr_* (e.g.
>ipmr_call_...). I personally prefer the ipmr prefix.

The naming scheme in this patch is aligned with the rest of the code.
Please see "call_netdevice_notifiers" for example.
Please feel free to send a patch to chanche them all.
