From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 3/4] net/core: Add violation counters to VF statisctics
Date: Mon, 28 Aug 2017 12:52:54 +0300
Message-ID: <CALzJLG9CXz3HcH1Uzyaz_NAyLPsc71n5tMpvMMW-=T79YY9Pgw@mail.gmail.com>
References: <20170827110618.20599-1-saeedm@mellanox.com> <20170827110618.20599-4-saeedm@mellanox.com>
 <20170827204306.0fb98e31@cakuba>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eugenia Emantayev <eugenia@mellanox.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34980 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750879AbdH1JxQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 05:53:16 -0400
Received: by mail-lf0-f66.google.com with SMTP id h132so21032lfh.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 02:53:15 -0700 (PDT)
In-Reply-To: <20170827204306.0fb98e31@cakuba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 3:43 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Sun, 27 Aug 2017 14:06:17 +0300, Saeed Mahameed wrote:
>> From: Eugenia Emantayev <eugenia@mellanox.com>
>>
>> Add receive and transmit violation counters to be
>> displayed in iproute2 VF statistics.
>>
>> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
>> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>> ---
>>  include/linux/if_link.h      |  2 ++
>>  include/uapi/linux/if_link.h |  2 ++
>>  net/core/rtnetlink.c         | 10 +++++++++-
>>  3 files changed, 13 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
>> index da70af27e42e..ebf3448acb5b 100644
>> --- a/include/linux/if_link.h
>> +++ b/include/linux/if_link.h
>> @@ -12,6 +12,8 @@ struct ifla_vf_stats {
>>       __u64 tx_bytes;
>>       __u64 broadcast;
>>       __u64 multicast;
>> +     __u64 rx_dropped;
>> +     __u64 tx_dropped;
>
> I'm a little concerned that you call those violation counters in the
> commit message.  Do you expect them to only be used if the VF traffic
> indeed violates some admin-set rules?  I would imaging HW/FW may drop
> frames in certain situations and naming the counters *_dropped suggests
> it would be OK to increment them even if the drop reason was not any
> sort of violation.  Would you mind clarifying?

Yes, the rx/tx_dropped counters serve as a general purpose VF drop
counter including VF violations.
We will fix the commit message.

Thanks !
Saeed.
