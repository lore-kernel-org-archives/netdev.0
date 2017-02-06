From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/7] openvswitch: Use inverted tuple in
 ovs_ct_find_existing() if NATted.
Date: Mon, 06 Feb 2017 12:15:12 -0500 (EST)
Message-ID: <20170206.121512.1686451353447088557.davem@davemloft.net>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org>
        <20170205.172824.848224453582586032.davem@davemloft.net>
        <CAOrHB_AWB7MFEHpeuKcG21s9QWjMHKC2zWNmXQLDo_5KZrnY6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarno@ovn.org, netdev@vger.kernel.org
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43490 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751001AbdBFRPN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 12:15:13 -0500
In-Reply-To: <CAOrHB_AWB7MFEHpeuKcG21s9QWjMHKC2zWNmXQLDo_5KZrnY6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@ovn.org>
Date: Mon, 6 Feb 2017 09:06:29 -0800

> On Sun, Feb 5, 2017 at 2:28 PM, David Miller <davem@davemloft.net> wrote:
>> From: Jarno Rajahalme <jarno@ovn.org>
>> Date: Thu,  2 Feb 2017 17:10:00 -0800
>>
>>> This does not match either of the conntrack tuples above.  Normally
>>> this does not matter, as the conntrack lookup was already done using
>>> the tuple (B,A), but if the current packet does not match any flow in
>>> the OVS datapath, the packet is sent to userspace via an upcall,
>>> during which the packet's skb is freed, and the conntrack entry
>>> pointer in the skb is lost.
>>
>> This is the real bug.
>>
>> If the metadata for a packet is important, as it obviously is here,
>> then upcalls should preserve that metadata across the upcall.  This
>> is exactly how NF_QUEUE handles this problem and so should OVS.
> 
> OVS kernel datapath serializes skb context and sends it along with skb
> during upcall via genetlink parameters. userspace echoes same
> information back to kernel modules. This way OVS does maintains
> metadata across upcall.

Then the conntrack state looked up before the NAT operation done in
the upcall should be maintained and therefore this bug should not
exist.
