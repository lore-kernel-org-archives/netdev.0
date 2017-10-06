From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC 1/3] tun: ethtool stats
Date: Fri, 6 Oct 2017 18:37:01 -0400
Message-ID: <CAF=yD-JZnJ4v3KZY2O3yBKWNnLxRBZJcJDVkYNuHYUZHX5Yw-Q@mail.gmail.com>
References: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
 <20171006222516.90654-2-willemdebruijn.kernel@gmail.com> <20171006153059.193688a5@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:56409 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751418AbdJFWhm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 18:37:42 -0400
Received: by mail-oi0-f67.google.com with SMTP id v9so19655385oif.13
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 15:37:42 -0700 (PDT)
In-Reply-To: <20171006153059.193688a5@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 6, 2017 at 6:30 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri,  6 Oct 2017 18:25:14 -0400
> Willem de Bruijn <willemdebruijn.kernel@gmail.com> wrote:
>
>> From: Willem de Bruijn <willemb@google.com>
>>
>> Support ethtool -S on tun devices. This interface allows exporting
>> device-specific stats not present in rtnl stats.
>>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>> ---
>>  drivers/net/tun.c | 38 ++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 38 insertions(+)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 57e4c31fa84a..df6ef9670d05 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -194,6 +194,15 @@ struct tun_flow_entry {
>>
>>  #define TUN_NUM_FLOW_ENTRIES 1024
>>
>> +static const struct {
>> +     const char string[ETH_GSTRING_LEN];
>> +} tun_ethtool_stats_keys[] = {
>> +     { "rx_packets" },
>> +     { "tx_packets" },
>> +     { "rx_bytes" },
>> +     { "tx_bytes" }
>
> It looks like you are just exporting the statistics taht are already
> through normal path. The purpose of ethtool stats is to provide
> statistics unique to the device, not to repeat what is available throug
> ip, ifconfig, etc.

A follow-up patch adds non-standard statistics.

I included these common ones, because the new zerocopy counters
are only interesting in relation to tx_packets.

It also seems customary among existing network drivers to include
at least these base counters in the ethtool output.
