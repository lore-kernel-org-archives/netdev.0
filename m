From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [PATCH 6/6] [net-next]net: i40e: Enable cloud filters in i40e via
 tc/flower classifier
Date: Wed, 2 Aug 2017 11:20:01 -0700
Message-ID: <62e2edac-521a-0e7b-4ca5-936d93c6a613@intel.com>
References: <150154569340.4135.11548126443780491627.stgit@anamdev.jf.intel.com>
 <150154788503.4135.7051219373661945937.stgit@anamdev.jf.intel.com>
 <f93480af-9ae0-2e02-7b11-78f8ab53899c@mojatatu.com>
 <30cd59b5-4175-8641-f288-a2373475837d@intel.com>
 <382b07c6-562b-9dc6-a4be-8f82819ab87a@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        netdev@vger.kernel.org, mitch.a.williams@intel.com,
        alexander.duyck@gmail.com, neerav.parikh@intel.com,
        sridhar.samudrala@intel.com, carolyn.wyborny@intel.com,
        Or Gerlitz <gerlitz.or@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55193 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751699AbdHBSUC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Aug 2017 14:20:02 -0400
In-Reply-To: <382b07c6-562b-9dc6-a4be-8f82819ab87a@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/2017 5:02 AM, Jamal Hadi Salim wrote:
> On 17-08-01 10:13 PM, Nambiar, Amritha wrote:
>>
>> On 8/1/2017 3:56 AM, Jamal Hadi Salim wrote:
>>> On 17-07-31 08:38 PM, Amritha Nambiar wrote:
>>>> This patch enables tc-flower based hardware offloads. tc/flower
>>>> filter provided by the kernel is configured as driver specific
>>>> cloud filter. The patch implements functions and admin queue
>>>> commands needed to support cloud filters in the driver and
>>>> adds cloud filters to configure these tc-flower filters.
>>>>
>>>> The only action supported is to redirect packets to a traffic class
>>>> on the same device.
>>>>
>>>> # tc qdisc add dev eth0 ingress
>>>> # ethtool -K eth0 hw-tc-offload on
>>>>
>>>> # tc filter add dev eth0 protocol ip parent ffff:\
>>>>     prio 1 flower dst_mac 3c:fd:fe:a0:d6:70 skip_sw indev eth0\
>>>>     action mirred ingress redirect dev eth0 tc 0
>>>>
>>>
>>> Out of curiosity - did you need to say "indev eth0" there?
>>
>> It looks like I don't need to specify "indev eth0". I will need to look
>> up how this part is offloaded and probably validate in the driver when
>> this is specified.
>>
>>> Also: Is it possible to add an skbmark? Example something like
>>> these that directs two flows to the same queue but different
>>> skb marks:
>>>
>>> # tc filter add dev eth0 protocol ip parent ffff: \
>>>     prio 2 flower dst_ip 192.168.3.5/32 \
>>>     ip_proto udp dst_port 2a skip_sw \
>>>     action skbedit mark 11 \
>>>     action mirred ingress redirect dev eth0 tcqueue 1
>>>
>>> # tc filter add dev eth0 protocol ip parent ffff: \
>>>       prio 1 flower dst_mac 3c:fd:fe:a0:d6:70 skip_sw \
>>>       action skbedit mark 12 \
>>>       action mirred ingress redirect dev eth0 tcqueue 1
>>>
>>
>> It is possible to support the skbedit mark action for the first rule
>> here (L3 and L4) which I can take up in a subsequent patch, but this
>> cannot be supported on our device for L2 based match in the second rule.
>>
> 
> Ok, thanks. So the issue is one of hardware limitation?
> 

Right. Our hardware does not have this support now.

> cheers,
> jamal
> 
