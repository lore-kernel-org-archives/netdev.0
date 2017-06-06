From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] bpf: Allow CGROUP_SKB eBPF program to
 access sk_buff
Date: Tue, 06 Jun 2017 16:40:26 -0400 (EDT)
Message-ID: <20170606.164026.1424601339058206000.davem@davemloft.net>
References: <CAMOXUJ=mUKvMMFnjfOUHuGms+p2fE+NkwEcORdV9eLBsFwyREQ@mail.gmail.com>
        <20170606.162602.345656836042086290.davem@davemloft.net>
        <59371023.605@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengc@google.com, chenbofeng.kernel@gmail.com,
        netdev@vger.kernel.org, lorenzo@google.com, ast@fb.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39904 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751426AbdFFUk2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 16:40:28 -0400
In-Reply-To: <59371023.605@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 06 Jun 2017 22:27:15 +0200

> On 06/06/2017 10:26 PM, David Miller wrote:
>> From: Chenbo Feng <fengc@google.com>
>> Date: Tue, 6 Jun 2017 13:24:11 -0700
>>
>>> On Tue, Jun 6, 2017 at 9:40 AM, Daniel Borkmann <daniel@iogearbox.net>
>>> wrote:
>>>
>>>> On 06/06/2017 02:04 PM, Daniel Borkmann wrote:
>>>>
>>>>> On 06/01/2017 03:15 AM, Chenbo Feng wrote:
>>>>>
>>>>>> From: Chenbo Feng <fengc@google.com>
>>>>>>
>>>>>> This allows cgroup eBPF program to classify packet based on their
>>>>>> protocol or other detail information. Currently program need
>>>>>> CAP_NET_ADMIN privilege to attach a cgroup eBPF program, and A
>>>>>> process with CAP_NET_ADMIN can already see all packets on the system,
>>>>>> for example, by creating an iptables rules that causes the packet to
>>>>>> be passed to userspace via NFLOG.
>>>>>>
>>>>>> Signed-off-by: Chenbo Feng <fengc@google.com>
>>>>>>
>>>>>
>>>>> Sorry, but I am puzzled what above change log has to do with the
>>>>> below diff?! Back then we decided not to add BPF_PROG_TYPE_CGROUP_SKB
>>>>> to may_access_skb(), since one can already use bpf_skb_load_bytes()
>>>>> helper to access pkt data, which is a much more flexible interface.
>>>>> Mind to elaborate why you cannot use bpf_skb_load_bytes() instead?
>>>>>
>>>>
>>>> See my other email [1], this one is also problematic wrt SKF_LL_OFF.
>>>>
>>>>    [1] http://patchwork.ozlabs.org/patch/771946/
>>>
>>>
>>> Oh sorry I just find out the bpf_skb_load_bytes helper already can
>>> achieve
>>> the goal. There is no point to add my patch then. Thanks you for
>>> pointing
>>> it out and fixing it.
>>
>> If something now needs to be reverted, you need to send that revert to
>> me.
> 
> It's sitting here: http://patchwork.ozlabs.org/patch/771946/

I see that now, applied to net-next, thanks!
