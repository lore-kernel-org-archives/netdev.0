From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/4] xps_flows: XPS flow steering when there is
 no socket
Date: Thu, 1 Sep 2016 12:32:03 -0700
Message-ID: <CALx6S35=n980YFKO1J0hQePzv-i1WH+mQYXOjn29T3691h_QiQ@mail.gmail.com>
References: <1472688605-2613704-1-git-send-email-tom@herbertland.com> <0f6c33fa-90cf-ae05-df8c-9eeb856228eb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Rick Jones <rick.jones2@hpe.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:36329 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755843AbcIAV0C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 17:26:02 -0400
Received: by mail-qk0-f181.google.com with SMTP id l2so99479038qkf.3
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 14:26:02 -0700 (PDT)
In-Reply-To: <0f6c33fa-90cf-ae05-df8c-9eeb856228eb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 1, 2016 at 12:25 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 08/31/2016 05:10 PM, Tom Herbert wrote:
>> This patch set introduces transmit flow steering for socketless packets.
>> The idea is that we record the transmit queues in a flow table that is
>> indexed by skbuff hash.  The flow table entries have two values: the
>> queue_index and the head cnt of packets from the TX queue. We only allow
>> a queue to change for a flow if the tail cnt in the TX queue advances
>> beyond the recorded head cnt. That is the condition that should indicate
>> that all outstanding packets for the flow have completed transmission so
>> the queue can change.
>>
>> Tracking the inflight queue is performed as part of DQL. Two fields are
>> added to the dql structure: num_enqueue_ops and num_completed_ops.
>> num_enqueue_ops incremented in dql_queued and num_completed_ops is
>> incremented in dql_completed by the number of operations completed (an
>> new argument to the function).
>>
>> This patch set creates /sys/class/net/eth*/xps_dev_flow_table_cnt
>> which number of entries in the XPS flow table.
>
> If you respin, do you mind updating the sysfs documentation at
> Documentation/ABI/testing/sysfs-class-net-queues with the new entries
> you are adding? Thanks!

There are no per-queue sysfs entries being added.

Tom

> --
> Florian
