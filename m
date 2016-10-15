From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 4/6] Introduce sample tc action
Date: Sat, 15 Oct 2016 10:31:20 -0700
Message-ID: <580267E8.70801@cumulusnetworks.com>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us> <1476276069-5315-5-git-send-email-jiri@resnulli.us> <58025A90.9010608@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:32982 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751519AbcJORbX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 13:31:23 -0400
Received: by mail-pf0-f178.google.com with SMTP id 128so63051390pfz.0
        for <netdev@vger.kernel.org>; Sat, 15 Oct 2016 10:31:23 -0700 (PDT)
In-Reply-To: <58025A90.9010608@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/16, 9:34 AM, Roopa Prabhu wrote:
> On 10/12/16, 5:41 AM, Jiri Pirko wrote:
>> From: Yotam Gigi <yotam.gi@gmail.com>
>>
>> This action allow the user to sample traffic matched by tc classifier.
>> The sampling consists of choosing packets randomly, truncating them,
>> adding some informative metadata regarding the interface and the original
>> packet size and mark them with specific mark, to allow further tc rules to
>> match and process. The marked sample packets are then injected into the
>> device ingress qdisc using netif_receive_skb.
>>
>> The packets metadata is packed using the ife encapsulation protocol, and
>> the outer packet's ethernet dest, source and eth_type, along with the
>> rate, mark and the optional truncation size can be configured from
>> userspace.
>>
>> Example:
>> To sample ingress traffic from interface eth1, and redirect the sampled
>> the sampled packets to interface dummy0, one may use the commands:
>>
>> tc qdisc add dev eth1 handle ffff: ingress
>>
>> tc filter add dev eth1 parent ffff: \
>> 	   matchall action sample rate 12 mark 17
>>
>> tc filter add parent ffff: dev eth1 protocol all \
>> 	   u32 match mark 172 0xff
>> 	   action mirred egress redirect dev dummy0
>>
>> Where the first command adds an ingress qdisc and the second starts
>> sampling every 12'th packet on dev eth0 and marks the sampled packets with
>> 17. The command third catches the sampled packets, which are marked with
>> 17, and redirects them to dev dummy0.
>>
>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> channeling some feedback from Peter Phaal @sflow inline below:
>
>
If it helps, one more thing that came up was using bpf.
They also use bpf filters for pkt sampling in the non-offloaded case:
http://blog.sflow.com/2016/05/berkeley-packet-filter-bpf.html

so, existing apps (like sflow) that care about packet sampling do prefer to use
a socket api for sample delivery: netlink nflog or bpf like socket filters

also, to keep the software and hardware models the same, wondering if ebpf attach
can be a viable option (have not thought about the offloaded case completely yet).
This would give apps more control on attaching sample headers (like sflow) if needed.

thanks,
Roopa
