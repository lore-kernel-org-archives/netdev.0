From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 4/6] bridge: a netlink notification should be
 sent when those attributes are changed by br_sysfs_br
Date: Wed, 16 Mar 2016 15:33:16 +0100
Message-ID: <56E96EAC.2080109@cumulusnetworks.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
 <059d608901fd86407fed374e567c46447aa8c88f.1458134414.git.lucien.xin@gmail.com>
 <f379a033c5b7798906c57dd1bb67df89b7de02cb.1458134414.git.lucien.xin@gmail.com>
 <45f430c026ce8a2fb358c650a41452aebff9ec36.1458134414.git.lucien.xin@gmail.com>
 <38a10eecc6347a3c47b55c86b4783c49b6dbbc99.1458134414.git.lucien.xin@gmail.com>
 <56E96A3B.1030907@cumulusnetworks.com>
 <CADvbK_fApZ76HLaVKHKukkfNMvg3b_Htz+n-vzni6H3eJPEf2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:33848 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933471AbcCPOdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 10:33:18 -0400
Received: by mail-wm0-f49.google.com with SMTP id p65so192889439wmp.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 07:33:18 -0700 (PDT)
In-Reply-To: <CADvbK_fApZ76HLaVKHKukkfNMvg3b_Htz+n-vzni6H3eJPEf2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2016 03:29 PM, Xin Long wrote:
> On Wed, Mar 16, 2016 at 10:14 PM, Nikolay Aleksandrov
> <nikolay@cumulusnetworks.com> wrote:
>> On 03/16/2016 02:34 PM, Xin Long wrote:
>>> Now when we change the attributes of bridge or br_port by netlink,
>>> a relevant netlink notification will be sent, but if we change them
>>> by ioctl or sysfs, no notification will be sent.
>>>
>>> We should ensure that whenever those attributes change internally or from
>>> sysfs/ioctl, that a netlink notification is sent out to listeners.
>>>
>>> Also, NetworkManager will use this in the future to listen for out-of-band
>>> bridge master attribute updates and incorporate them into the runtime
>>> configuration.
>>>
>>> This patch is used for br_sysfs_br. and we also need to remove some
>>> rtnl_trylock in old functions so that we can call it in a common one.
>>>
>>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>>> ---
>>>  net/bridge/br_sysfs_br.c | 17 ++++++++---------
>>>  net/bridge/br_vlan.c     | 30 +++++-------------------------
>>>  2 files changed, 13 insertions(+), 34 deletions(-)
>>>
>>
>> What about the group_addr option ? Changing it will not generate a notification.
>>
>>
> 
> group_addr is not a string-to-long convert in sysfs. so it's hard to use
> store_bridge_parm, that's why I didn't modify it.
> 
> in group_addr_store():
> it also tries to hold rtnl_lock. maybe we can send rtnl msg there.
> what do you think?
Sounds good.

> 
> when I cooked this patch, I was wondering why br_recalculate_fwd_mask
> "Must be protected by RTNL."
> 
vlan_enabled and vlan_proto are changed under rtnl, also this can race with
changing via netlink
