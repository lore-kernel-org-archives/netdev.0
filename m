From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 01/20] net: sched: add block bind/unbind notif.
 and extended block_get/put
Date: Thu, 19 Oct 2017 15:13:57 +0200
Message-ID: <20171019131357.GB1978@nanopsycho.orion>
References: <20171017200615.4530-1-jiri@resnulli.us>
 <20171017200615.4530-2-jiri@resnulli.us>
 <20171019.132311.905310714904196268.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:56385 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752498AbdJSNN7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 09:13:59 -0400
Received: by mail-wm0-f66.google.com with SMTP id l68so16310075wmd.5
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 06:13:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171019.132311.905310714904196268.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 19, 2017 at 02:23:11PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Tue, 17 Oct 2017 22:05:56 +0200
>
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
>Like David I think you should add this to the end of the list.
>
>If you don't "think" about backporting issues when doing upstream
>work, you're not "think"ing about some of the people who end up using
>your code.

Okay, I don't mind much putting this at the end. I did a lot of
backports in my life, things like this are the easiest to handle, that's
why I don't believe we should consider it. :)

There are much more problematic things during backport, like changes of
parameters of exported functions or adding fields to structs.
That we correctly don't care about upstream. Now we care about adding
new enum values to the end? That does not make sense to me, sorry :/

For the clarity, I know why I say "people should not think about
backporting while working on features upstream". I was in position
of adding a feature and doing the backport of it many times. The reason
is simply because people would tend to do non-optimal solution just
because it will be easy to backport and their work would be easier.
