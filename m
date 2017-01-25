From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net PATCH v5 1/6] virtio_net: use dev_kfree_skb for small buffer
 XDP receive
Date: Wed, 25 Jan 2017 13:46:46 +0800
Message-ID: <46915782-1c3f-04a9-ae0a-84e5f805af1f@redhat.com>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
 <20170117221950.20280.39496.stgit@john-Precision-Tower-5810>
 <20170123230809-mutt-send-email-mst@kernel.org>
 <20170124.144328.2195698124358175034.davem@davemloft.net>
 <20170124215412-mutt-send-email-mst@kernel.org>
 <a129524e-c4af-5c67-5397-dec992c70fa1@redhat.com>
 <20170125051810-mutt-send-email-mst@kernel.org> <58882355.70307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35022 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751278AbdAYFqx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 00:46:53 -0500
In-Reply-To: <58882355.70307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月25日 12:02, John Fastabend wrote:
> On 17-01-24 07:23 PM, Michael S. Tsirkin wrote:
>> On Wed, Jan 25, 2017 at 10:57:12AM +0800, Jason Wang wrote:
>>> On 2017年01月25日 04:08, Michael S. Tsirkin wrote:
>>>> On Tue, Jan 24, 2017 at 02:43:28PM -0500, David Miller wrote:
>>>>> From: "Michael S. Tsirkin"<mst@redhat.com>
>>>>> Date: Mon, 23 Jan 2017 23:08:35 +0200
>>>>>
>>>>>> On Tue, Jan 17, 2017 at 02:19:50PM -0800, John Fastabend wrote:
>>>>>>> In the small buffer case during driver unload we currently use
>>>>>>> put_page instead of dev_kfree_skb. Resolve this by adding a check
>>>>>>> for virtnet mode when checking XDP queue type. Also name the
>>>>>>> function so that the code reads correctly to match the additional
>>>>>>> check.
>>>>>>>
>>>>>>> Fixes: bb91accf2733 ("virtio-net: XDP support for small buffers")
>>>>>>> Signed-off-by: John Fastabend<john.r.fastabend@intel.com>
>>>>>>> Acked-by: Jason Wang<jasowang@redhat.com>
>>>>>> Acked-by: Michael S. Tsirkin<mst@redhat.com>
>>>>>>
>>>>>> I think we definitely want this one in -net as it's
>>>>>> a bugfix.
>>>>> This whole series is a bug fix, we must have adjust_header XDP
>>>>> support in the virtio_net driver before v4.10 goes out, it is
>>>>> a requires base feature for XDP.
>>>> I have to say device resets outside probe have a huge potential
>>>> to uncover hypervisor bugs.
>>> Maybe not if it reuses most of current codes? Since we've already used them
>>> in sleep or hibernation?
>>>
>>> Thanks
>> Except almost no one uses sleep or hybernate with VMs.  I'm not saying
>> it's a bad idea, just that it needs a lot of testing before release and
>> we won't get enough if we merge at this point.
>>
> Then it would seem like a good thing to have another user of these paths and
> find the bugs versus letting them sit there for some poor folks who do use
> sleep/hybernate.
>

Yes, and uncovering hypervisor bugs now is better than uncovering it in 
the future.

Thanks
