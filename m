From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net-next v2 1/1] driver: ipvlan: Use NF_IP_PRI_LAST as
 hook priority instead of INT_MAX
Date: Tue, 29 Nov 2016 09:14:45 +0800
Message-ID: <CA+6hz4qXYzC-mEfTqa5HOf9GtL1S1Q=rcz_CtFW5mbvUtj7niA@mail.gmail.com>
References: <1480245482-10357-1-git-send-email-fgao@ikuai8.com> <CAF2d9jhdJ55ednEnj7PUezRJ+HJ-3PTH0=B3D9DyYtDVp7RBfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        linux-netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg202.qq.com ([184.105.206.29]:36500 "EHLO smtpbg202.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754906AbcK2BPK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 20:15:10 -0500
Received: from mail-vk0-f41.google.com (unknown [209.85.213.41])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 09:14:46 +0800 (CST)
Received: by mail-vk0-f41.google.com with SMTP id x186so83803023vkd.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 17:14:47 -0800 (PST)
In-Reply-To: <CAF2d9jhdJ55ednEnj7PUezRJ+HJ-3PTH0=B3D9DyYtDVp7RBfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mahesh,

On Tue, Nov 29, 2016 at 3:26 AM, Mahesh Bandewar (महेश बंडेवार)
<maheshb@google.com> wrote:
> On Sun, Nov 27, 2016 at 3:18 AM,  <fgao@ikuai8.com> wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> It is better to use NF_IP_PRI_LAST instead of INT_MAX as hook priority.
>> The former is good at readability and easier to maintain.
>>
> This IPvlan hook has to be "absolute" last hook and at this moment
> NF_IP_PRI_LAST is set as INT_MAX so it's not altering anything.

Yes. It is same now.
So I prefer to use NF_IP_PRI_LAST than INT_MAX.
Because the nf_hook_ops belongs to the netfilter module. i think the
ipvlan codes should follow its rule.
Since netfilter has defined some specific priority enum value, why
don't we follow it?

>
> If for whatever reasons the value of NF_IP_PRI_LAST changes, there
> could be random IPvlan failure. Since that possibility cannot be
> denied and there are several places INT_MAX is still used as hook
> priority, I don't see any gain in having this patch in fact there
> could be future (possible) downside.

If the netfilter module changed the value of NF_IP_PRI_LAST, it may
decrease it and add one check for the hook priority.
As a result, the ipvlan may fail to register because of invalid priority.

When use INT_MAX not NF_IP_PRI_LAST, there is one assumption that the
hook priority is never changed.
I think it is not good as two different modules.

Regards
Feng

>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> ---
>>  v2: Add the lost header file. It is added in local but not in v1 patch
>>  v1: Inital patch
>>
>>  drivers/net/ipvlan/ipvlan_main.c | 5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
>> index ab90b22..01c7446 100644
>> --- a/drivers/net/ipvlan/ipvlan_main.c
>> +++ b/drivers/net/ipvlan/ipvlan_main.c
>> @@ -7,6 +7,7 @@
>>   *
>>   */
>>
>> +#include "linux/netfilter_ipv4.h"
>>  #include "ipvlan.h"
>>
>>  static u32 ipvl_nf_hook_refcnt = 0;
>> @@ -16,13 +17,13 @@
>>                 .hook     = ipvlan_nf_input,
>>                 .pf       = NFPROTO_IPV4,
>>                 .hooknum  = NF_INET_LOCAL_IN,
>> -               .priority = INT_MAX,
>> +               .priority = NF_IP_PRI_LAST,
>>         },
>>         {
>>                 .hook     = ipvlan_nf_input,
>>                 .pf       = NFPROTO_IPV6,
>>                 .hooknum  = NF_INET_LOCAL_IN,
>> -               .priority = INT_MAX,
>> +               .priority = NF_IP_PRI_LAST,
>>         },
>>  };
>>
>> --
>> 1.9.1
>>
>>
