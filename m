From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Wed, 2 Aug 2017 10:08:35 -0500
Message-ID: <115c4698-cfcb-83dc-e70b-89207ef326a8@codeaurora.org>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-2-git-send-email-timur@codeaurora.org>
 <063D6719AE5E284EB5DD2968C1650D6DD00490C0@AcuExch.aculab.com>
 <77de100a-42b1-1e0d-6545-cadb0067eec6@codeaurora.org>
 <063D6719AE5E284EB5DD2968C1650D6DD00491F6@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:52572 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752262AbdHBPIh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 11:08:37 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD00491F6@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2017 09:51 AM, David Laight wrote:
> Sending pause frames just tells the adjacent switch not to send you packets
> (because you'll discard them).
> Since the idea is to avoid the discards, the switch will buffer the
> packets it would have sent.
> The buffers in the switch then fill up with packets it isn't sending you.

I was under the impression that the switch forwards the pause frames to 
other devices, so that the transmitting NIC can stop sending the data, 
but your explanation makes a lot more sense.  If the EMAC never stops 
sending pause frames, then the switch's buffers will fill up, disabling 
all other devices.  If the switch does not have per-port buffers, then 
it makes sense when the buffer is full, it blocks all ports.

> The switch then runs out of buffers, it has 2 choices:
> 1) Throw the packets away.
> 2) Send 'pause' frames to the sources.
> If it sends 'pause' frames the entire network will very quickly lock up.
> If it discards the packets they might as well have been discarded by the
> receiving MAC.
> 
> Doesn't this mean that pause frames are 99.999% useless??

Pause frames are intended for situations where the receiving CPU is 
temporarily overwhelmed and just needs a second or two to resume 
processing incoming packets.  That makes sense on a dinky single-core 
32-bit CPU.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
