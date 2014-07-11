From: Sharat Masetty <sharat04@gmail.com>
Subject: Re: [PATCH v2 0/4] net: Checksum offload changes - Part IV
Date: Thu, 10 Jul 2014 23:40:51 -0600
Message-ID: <CAJzFV35iTRbgECjg5S3bL025E4b8A3c1sBhfZX=OY3njFDYYoQ@mail.gmail.com>
References: <alpine.DEB.2.02.1406101848350.5666@tomh.mtv.corp.google.com>
	<20140611.154635.2203844517927313680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:58541 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbaGKFkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 01:40:52 -0400
Received: by mail-we0-f172.google.com with SMTP id u57so523510wes.31
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 22:40:51 -0700 (PDT)
In-Reply-To: <20140611.154635.2203844517927313680.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Don't do skb_checksum more than once per packet
Was wondering in which cases does the stack perform the checksum more
than once? __skb_checksum_complete_head() already sets the ip_summed
to CHECKSUM_UNNECESSARY, so future checksum calculations are avoided.
What am I missing?

Thanks
Sharat

On Wed, Jun 11, 2014 at 4:46 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Tue, 10 Jun 2014 18:54:03 -0700 (PDT)
>
>> I am working on overhauling RX checksum offload. Goals of this effort
>> are:
>>
>> - Specify what exactly it means when driver returns CHECKSUM_UNNECESSARY
>> - Preserve CHECKSUM_COMPLETE through encapsulation layers
>> - Don't do skb_checksum more than once per packet
>> - Unify GRO and non-GRO csum verification as much as possible
>> - Unify the checksum functions (checksum_init)
>> - Simply code
>>
>> What is in this fourth patch set:
>>
>> - Preserve CHECKSUM_COMPLETE instead of changing it to
>>   CHECKSUM_UNNECESSARY. This allows correct reuse in validating multiple
>>   csums in a packet.
>> - When SW needs to compute the packet checksum, save it as
>>   CHECKSUM_COMPLETE. Also mark that checksum was compute by SW.
>> - Add skb_gro_postpull_rcsum to udp and vxlan to make GRO work with
>>   CHECKSUM_COMPLETE.
>>
>> v2: Removed patch setting skb_encapsulation when validating checksum
>>     in tcp_gro_receive
>>
>> Please review carefully and test if possible, mucking with basic
>> checksum functions is always a little precarious :-)
>
> Series applied, thanks Tom.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
