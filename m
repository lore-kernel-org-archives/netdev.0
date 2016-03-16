From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next 5/6] bridge: a netlink notification should be
 sent when those attributes are changed by br_sysfs_if
Date: Wed, 16 Mar 2016 22:45:12 +0800
Message-ID: <CADvbK_eZUKV21x241heK45D9j62Fg7fZqd5rgG-S_LPed2WGjw@mail.gmail.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
	<059d608901fd86407fed374e567c46447aa8c88f.1458134414.git.lucien.xin@gmail.com>
	<f379a033c5b7798906c57dd1bb67df89b7de02cb.1458134414.git.lucien.xin@gmail.com>
	<45f430c026ce8a2fb358c650a41452aebff9ec36.1458134414.git.lucien.xin@gmail.com>
	<38a10eecc6347a3c47b55c86b4783c49b6dbbc99.1458134414.git.lucien.xin@gmail.com>
	<7c788b65786582209a3ba4bc4d4ed279f6f77568.1458134414.git.lucien.xin@gmail.com>
	<56E96C4C.8060407@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33268 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933471AbcCPOpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 10:45:13 -0400
Received: by mail-oi0-f65.google.com with SMTP id c203so2615559oia.0
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 07:45:12 -0700 (PDT)
In-Reply-To: <56E96C4C.8060407@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2016 at 10:23 PM, Nikolay Aleksandrov
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
>> This patch is used for br_sysfs_if, and we also move br_ifinfo_notify out
>> of store_flag.
>>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> ---
>>  net/bridge/br_sysfs_if.c | 5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
>>
>
> Generally looks good, but it creates an inconsistency between bridge fdb_flush
> and port fdb_flush since the latter will generate a notification while the
> bridge flush will not.
>
yeah, because port fdb_flush is called by brport_store(), in the
common function.
do you think it''s redundant if we add a notification in bridge
fdb_flush to keep
consistence with port fdb_flush?
