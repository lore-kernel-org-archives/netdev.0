From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 01/20] net: sched: add block bind/unbind notif.
 and extended block_get/put
Date: Wed, 18 Oct 2017 08:59:25 +0200
Message-ID: <20171018065925.GA2028@nanopsycho>
References: <20171017200615.4530-1-jiri@resnulli.us>
 <20171017200615.4530-2-jiri@resnulli.us>
 <1508271733.11655.3.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "leonro@mellanox.com" <leonro@mellanox.com>,
        "idosch@mellanox.com" <idosch@mellanox.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "ast@kernel.org" <ast@kernel.org>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "saeedm@mellanox.com" <saeedm@mellanox.com>,
        "mlxsw@mellanox.com" <mlxsw@mellanox.com>,
        "john.hurley@netronome.com" <john.hurley@netronome.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "jakub.kicinski@netronome.com" <jakub.kicinski@netronome.com>,
        "ganeshgr@chelsio.com" <ganeshgr@chelsio.com>,
        "simon.horman@netronome.com" <simon.horman@netronome.com>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:48965 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761219AbdJRG72 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 02:59:28 -0400
Received: by mail-wr0-f194.google.com with SMTP id u5so3915398wrc.5
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 23:59:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1508271733.11655.3.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 17, 2017 at 10:22:16PM CEST, alexander.h.duyck@intel.com wrote:
>On Tue, 2017-10-17 at 22:05 +0200, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Introduce new type of ndo_setup_tc message to propage binding/unbinding
>> of a block to driver. Call this ndo whenever qdisc gets/puts a block.
>> Alongside with this, there's need to propagate binder type from qdisc
>> code down to the notifier. So introduce extended variants of
>> block_get/put in order to pass this info.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  include/linux/netdevice.h |  1 +
>>  include/net/pkt_cls.h     | 40 +++++++++++++++++++++++++++++++++
>>  net/sched/cls_api.c       | 56 ++++++++++++++++++++++++++++++++++++++++++++---
>>  3 files changed, 94 insertions(+), 3 deletions(-)
>> 
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 31bb301..062a4f5 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -771,6 +771,7 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>>  
>>  enum tc_setup_type {
>>  	TC_SETUP_MQPRIO,
>> +	TC_SETUP_BLOCK,
>>  	TC_SETUP_CLSU32,
>>  	TC_SETUP_CLSFLOWER,
>>  	TC_SETUP_CLSMATCHALL,
>
>I'm not a big fan of adding this to the middle of the enum. It will
>make it harder for people that have to backport changes and such since
>it is reordering values that are passed as a part of the kabi between
>drivers and the kernel.

I put it where I think it fits. I never think about backport while
working on upstream kernel. I believe it is a bad practise if you do so.
But in this case, the backport is trivial, I don't see any problem with
that.


>
>Also does this patch set really need to be 20 patches long? Seems like
>you could have done this as a set of 8 and another of 12 since you need
>about 8 patches to get to the point where you start pulling the code
>out of the drivers.

Yeah, basically I can cut the patchset in any place. But I wanted to
show the whole change. If there was more drivers using this, I would
have to add patches. Cutting it in half just because of the amount feels
wrong, it's half way through there :/ If you insist, I can cut it. I can
even squash multiple patches to one. But that also feels wrong :/
