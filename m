From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH] macvlan: resolve ENOENT errors on creation
Date: Mon, 21 Oct 2013 14:48:55 -0700
Message-ID: <5265A147.4010501@gmail.com>
References: <20131021212801.19330.69659.stgit@nitbit.x32> <20131021213441.GB18170@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:58240 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941Ab3JUVtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 17:49:15 -0400
Received: by mail-oa0-f45.google.com with SMTP id i4so5702064oah.18
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 14:49:14 -0700 (PDT)
In-Reply-To: <20131021213441.GB18170@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2013 02:34 PM, Veaceslav Falico wrote:
> On Mon, Oct 21, 2013 at 02:28:02PM -0700, John Fastabend wrote:
>> After the commit below attempting to create macvlan devices was
>> resulting in ENOENT errors,
>>
>> # ip link add link p3p2 type macvlan
>> RTNETLINK answers: Invalid argument
>>
>> This happens because netdev_upper_dev_link() is called before
>> register_netdevice() in the macvlan code. Through a call chain
>> this results in a call to __netdev_adjacent_dev_insert() and
>> finally a sysfs_create_link(). This requires the kobject of
>> the macvlan to be registered which is done in register_netdevice().
>> If there is no kobject which is the case here the ENOENT error
>> is seen on the command line.
>>
>> To resolve this move the netdev_upper_dev_link() call below
>> the register_netdevice() call. This aligns with vlan driver
>> flow.
>
> Yep, changed the vlan code, but didn't see the macvlan. My cscope didn't
> catch it for some reason :-/.
>
> I've also checked - there are no users except bonding, vlan (both are ok),
> and macvlan.
>

The openvswitch code uses netdev_master_upper_dev_link() which
eventually calls __netdev_adjacent_dev_insert() as well. But from
a quick code inspection I think it should work. Anyways that is one
other user.

.John

-- 
John Fastabend         Intel Corporation
