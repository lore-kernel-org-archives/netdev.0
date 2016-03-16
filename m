From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next 4/6] bridge: a netlink notification should be
 sent when those attributes are changed by br_sysfs_br
Date: Wed, 16 Mar 2016 22:29:05 +0800
Message-ID: <CADvbK_fApZ76HLaVKHKukkfNMvg3b_Htz+n-vzni6H3eJPEf2Q@mail.gmail.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
	<059d608901fd86407fed374e567c46447aa8c88f.1458134414.git.lucien.xin@gmail.com>
	<f379a033c5b7798906c57dd1bb67df89b7de02cb.1458134414.git.lucien.xin@gmail.com>
	<45f430c026ce8a2fb358c650a41452aebff9ec36.1458134414.git.lucien.xin@gmail.com>
	<38a10eecc6347a3c47b55c86b4783c49b6dbbc99.1458134414.git.lucien.xin@gmail.com>
	<56E96A3B.1030907@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35331 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935033AbcCPO3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 10:29:06 -0400
Received: by mail-oi0-f66.google.com with SMTP id r187so2585593oih.2
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 07:29:05 -0700 (PDT)
In-Reply-To: <56E96A3B.1030907@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2016 at 10:14 PM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> On 03/16/2016 02:34 PM, Xin Long wrote:
>> Now when we change the attributes of bridge or br_port by netlink,
>> a relevant netlink notification will be sent, but if we change them
>> by ioctl or sysfs, no notification will be sent.
>>
>> We should ensure that whenever those attributes change internally or from
>> sysfs/ioctl, that a netlink notification is sent out to listeners.
>>
>> Also, NetworkManager will use this in the future to listen for out-of-band
>> bridge master attribute updates and incorporate them into the runtime
>> configuration.
>>
>> This patch is used for br_sysfs_br. and we also need to remove some
>> rtnl_trylock in old functions so that we can call it in a common one.
>>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> ---
>>  net/bridge/br_sysfs_br.c | 17 ++++++++---------
>>  net/bridge/br_vlan.c     | 30 +++++-------------------------
>>  2 files changed, 13 insertions(+), 34 deletions(-)
>>
>
> What about the group_addr option ? Changing it will not generate a notification.
>
>

group_addr is not a string-to-long convert in sysfs. so it's hard to use
store_bridge_parm, that's why I didn't modify it.

in group_addr_store():
it also tries to hold rtnl_lock. maybe we can send rtnl msg there.
what do you think?

when I cooked this patch, I was wondering why br_recalculate_fwd_mask
"Must be protected by RTNL."
