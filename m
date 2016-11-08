From: Jason Wang <jasowang@redhat.com>
Subject: Re: Virtio_net support vxlan encapsulation package TSO offload
 discuss
Date: Tue, 8 Nov 2016 19:17:25 +0800
Message-ID: <3a0b8f10-f479-3ed5-dd10-5b92de3eb593@redhat.com>
References: <DBCD2614ECF3FF4087A2C27CA80E34DD5401AC8B@SZXEMA501-MBX.china.huawei.com>
 <c2f735e4-eddf-f737-2afe-35a93289f8d4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Vlad Yasevic <vyasevic@redhat.com>
To: "Zhangming (James, Euler)" <james.zhangming@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36462 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932582AbcKHLRb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Nov 2016 06:17:31 -0500
In-Reply-To: <c2f735e4-eddf-f737-2afe-35a93289f8d4@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016年11月08日 19:13, Jason Wang wrote:
> Cc Michael
>
> On 2016年11月08日 16:34, Zhangming (James, Euler) wrote:
>>
>> In container scenario, OVS is installed in the Virtual machine, and 
>> all the containers connected to the OVS will communicated through 
>> VXLAN encapsulation.
>>
>> By now, virtio_net does not support TSO offload for VXLAN 
>> encapsulated TSO package. In this condition, the performance is not 
>> good, sender is bottleneck
>>
>> I googled this scenario, but I didn’t find any information. Will 
>> virtio_net support VXLAN encapsulation package TSO offload later?
>>
>
> Yes and for both sender and receiver.
>
>> My idea is virtio_net open encapsulated TSO offload, and transport 
>> encapsulation info to TUN, TUN will parse the info and build skb with 
>> encapsulation info.
>>
>> OVS or kernel on the host should be modified to support this. Using 
>> this method, the TCP performance aremore than 2x as before.
>>
>> Any advice and suggestions for this idea or new idea will be greatly 
>> appreciated!
>>
>> Best regards,
>>
>>    James zhang
>>
>
> Sounds very good. And we may also need features bits 
> (VIRTIO_NET_F_GUEST|HOST_GSO_X) for this.
>
> This is in fact one of items in networking todo list. (See 
> http://www.linux-kvm.org/page/NetworkingTodo). While at it, we'd 
> better support not only VXLAN but also other tunnels.

Cc Vlad who is working on extending virtio-net headers.

>
> We can start with the spec work, or if you've already had some bits 
> you can post them as RFC for early review.
>
> Thanks
