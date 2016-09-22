From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/6] fib: introduce FIB notification
 infrastructure
Date: Thu, 22 Sep 2016 11:43:56 +0200
Message-ID: <20160922094356.GA1830@nanopsycho.orion>
References: <1474458794-5512-1-git-send-email-jiri@resnulli.us>
 <1474458794-5512-2-git-send-email-jiri@resnulli.us>
 <20160922051350.GA24119@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com,
        andy@greyhouse.net, f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        jhs@mojatatu.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com, kaber@trash.net,
        john@phrozen.org
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34329 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbcIVJn7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 05:43:59 -0400
Received: by mail-wm0-f66.google.com with SMTP id l132so12983183wmf.1
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 02:43:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160922051350.GA24119@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Sep 22, 2016 at 07:13:50AM CEST, idosch@idosch.org wrote:
>On Wed, Sep 21, 2016 at 01:53:09PM +0200, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> This allows to pass information about added/deleted FIB entries/rules to
>> whoever is interested. This is done in a very similar way as devinet
>> notifies address additions/removals.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>[...]
>
>>  #include <linux/slab.h>
>>  #include <linux/export.h>
>>  #include <linux/vmalloc.h>
>> +#include <linux/notifier.h>
>>  #include <net/net_namespace.h>
>>  #include <net/ip.h>
>>  #include <net/protocol.h>
>> @@ -84,6 +85,44 @@
>>  #include <trace/events/fib.h>
>>  #include "fib_lookup.h"
>>  
>> +static BLOCKING_NOTIFIER_HEAD(fib_chain);
>> +
>> +int register_fib_notifier(struct notifier_block *nb)
>> +{
>> +	return blocking_notifier_chain_register(&fib_chain, nb);
>> +}
>> +EXPORT_SYMBOL(register_fib_notifier);
>
>If we remove and insert the switch driver, then the existing FIB entries
>should be replayed when we register our notification block. Otherwise,
>all of these entries will be missing from the switch's tables. I believe
>it should be handled like register_netdevice_notifier(), where
>"registration and up events are replayed".

Agreed. This patchset does not change this behaviour as the original
switchdev solution has the same "ordering" issue. We should take care of
it as a part of yours ordering patchsets.
