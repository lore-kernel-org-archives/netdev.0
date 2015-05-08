From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: Multiqueue pktgen and ingress path (Was: [PATCH v5 2/2] pktgen:
 introduce xmit_mode '<start_xmit|netif_receive>')
Date: Fri, 08 May 2015 10:00:34 -0700
Message-ID: <554CEBB2.8040908@plumgrid.com>
References: <20150507143329.8534.49710.stgit@ivy>	<20150507143500.8534.4435.stgit@ivy>	<554B9293.2070702@plumgrid.com>	<554B9CDE.1050703@iogearbox.net>	<20150508173900.3fcf78de@redhat.com> <20150508174927.5b1ecdd1@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:36423 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932324AbbEHRAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 13:00:34 -0400
Received: by iecnq11 with SMTP id nq11so68402045iec.3
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 10:00:33 -0700 (PDT)
In-Reply-To: <20150508174927.5b1ecdd1@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/8/15 8:49 AM, Jesper Dangaard Brouer wrote:
>>
>> I've added a more plain version of a script, based on yours, below my
>> signature.
>
> Now attached.

thanks for the script! Really useful.
Could you add it to samples/pktgen/ and remove useless and confusing
pktgen.conf-2-1 ?

>> The funny thing now is that scaling does not "happen" as we stall on:
>>     atomic_long_inc(&skb->dev->rx_dropped);
>
> More interesting observations with the mentioned script (now attached).
>
> On my system the scaling stopped a 24Mpps, when I increased the number
> of threads the collective scaling was stuck at 24Mpps.

what was your config to start hitting that drop counter?
We can convert it to per_cpu, but I'm not sure it's worth doing.
If I send normal ip packets they don't go this path. Only
unknown protocol packets suppose to hit it ?
