From: Andrew Collins <acollins@cradlepoint.com>
Subject: Re: [RFC] Add netdev all_adj_list refcnt propagation to fix panic
Date: Wed, 30 Mar 2016 14:32:44 -0600
Message-ID: <56FC37EC.7020404@cradlepoint.com>
References: <1459272303-8851-1-git-send-email-acollins@cradlepoint.com>
 <20160330.160150.1290720758360796805.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <mschiffer@universe-factory.net>,
	<vfalico@redhat.com>, <vfalico@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0119.outbound.protection.outlook.com ([157.56.110.119]:59938
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752321AbcC3VF3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2016 17:05:29 -0400
In-Reply-To: <20160330.160150.1290720758360796805.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Andrew Collins <acollins@cradlepoint.com>
> Date: Tue, 29 Mar 2016 11:25:03 -0600
>
>> This is an RFC patch to fix a relatively easily reproducible kernel
>> panic related to the all_adj_list handling for netdevs in recent kernels.
>>
>> This is more to generate discussion than anything else.  I don't
>> particularly like this approach, I'm hoping someone has a better idea.
>>
>> The following sequence of commands will reproduce the issue:
>>
>> ip link add link eth0 name eth0.100 type vlan id 100
>> ip link add link eth0 name eth0.200 type vlan id 200
>> ip link add name testbr type bridge
>> ip link set eth0.100 master testbr
>> ip link set eth0.200 master testbr
>> ip link add link testbr mac0 type macvlan
>> ip link delete dev testbr
>>
>> This creates an upper/lower tree of (excuse the poor ASCII art):
>>
>>              /---eth0.100-eth0
>> mac0-testbr-
>>              \---eth0.200-eth0
>>
>> When testbr is deleted, the all_adj_lists are walked, and eth0 is deleted twice from
>> the mac0 list. Unfortunately, during setup in __netdev_upper_dev_link, only one
>> reference to eth0 is added, so this results in a panic.
>>
>> This change adds reference count propagation so things are handled properly.
>>
>> Matthias Schiffer reported a similar crash in batman-adv:
>>
>> https://github.com/freifunk-gluon/gluon/issues/680
>> https://www.open-mesh.org/issues/247
>>
>> which this patch also seems to resolve.
>
> Veaceslav, please look into this.
>
> Thanks.
>
> !SIG:56fc30b5184771297483788!
>

+vfalico's new address picked up from git logs
