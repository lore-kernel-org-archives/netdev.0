From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] net: sched: fix use-after-free in tcf_action_destroy
 and tcf_del_walker
Date: Wed, 13 Sep 2017 22:50:06 +0200
Message-ID: <20170913205006.GD1981@nanopsycho>
References: <20170913153237.26408-1-jiri@resnulli.us>
 <20170913.093428.806129519464331602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        kubakici@wp.pl, mlxsw@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:38039 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751400AbdIMUuJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 16:50:09 -0400
Received: by mail-wr0-f193.google.com with SMTP id p37so648980wrb.5
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 13:50:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170913.093428.806129519464331602.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 13, 2017 at 06:34:28PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed, 13 Sep 2017 17:32:37 +0200
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Recent commit d7fb60b9cafb ("net_sched: get rid of tcfa_rcu") removed
>> freeing in call_rcu, which changed already existing hard-to-hit
>> race condition into 100% hit:
>> 
>> [  598.599825] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
>> [  598.607782] IP: tcf_action_destroy+0xc0/0x140
>> 
>> Or:
>> 
>> [   40.858924] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
>> [   40.862840] IP: tcf_generic_walker+0x534/0x820
>> 
>> Fix this by storing the ops and use them directly for module_put call.
>> 
>> Fixes: a85a970af265 ("net_sched: move tc_action into tcf_common")
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>Applied, thanks Jiri.

Oh, I forgot to mention, this would be nice to push to stable.
