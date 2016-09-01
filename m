From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/4] xps_flows: XPS flow steering when there is
 no socket
Date: Thu, 1 Sep 2016 12:25:30 -0700
Message-ID: <0f6c33fa-90cf-ae05-df8c-9eeb856228eb@gmail.com>
References: <1472688605-2613704-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, rick.jones2@hpe.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33261 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752172AbcIAVLC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 17:11:02 -0400
Received: by mail-pf0-f181.google.com with SMTP id g202so11885038pfb.0
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 14:11:02 -0700 (PDT)
In-Reply-To: <1472688605-2613704-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2016 05:10 PM, Tom Herbert wrote:
> This patch set introduces transmit flow steering for socketless packets.
> The idea is that we record the transmit queues in a flow table that is
> indexed by skbuff hash.  The flow table entries have two values: the
> queue_index and the head cnt of packets from the TX queue. We only allow
> a queue to change for a flow if the tail cnt in the TX queue advances
> beyond the recorded head cnt. That is the condition that should indicate
> that all outstanding packets for the flow have completed transmission so
> the queue can change.
> 
> Tracking the inflight queue is performed as part of DQL. Two fields are
> added to the dql structure: num_enqueue_ops and num_completed_ops.
> num_enqueue_ops incremented in dql_queued and num_completed_ops is
> incremented in dql_completed by the number of operations completed (an
> new argument to the function).
> 
> This patch set creates /sys/class/net/eth*/xps_dev_flow_table_cnt
> which number of entries in the XPS flow table.

If you respin, do you mind updating the sysfs documentation at
Documentation/ABI/testing/sysfs-class-net-queues with the new entries
you are adding? Thanks!
-- 
Florian
