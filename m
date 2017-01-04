From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH] net: virtio: cap mtu when XDP programs are running
Date: Wed, 4 Jan 2017 10:57:19 -0800
Message-ID: <586D458F.5050705@gmail.com>
References: <20170102223031.11541.28717.stgit@john-Precision-Tower-5810>
 <402027b4-58c7-aa1b-5079-74e31448f544@redhat.com>
 <586BD5D5.6020100@gmail.com>
 <1caf1ffc-0f46-067e-0f0d-a93b408b4ffd@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35078 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934112AbdADS6E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 13:58:04 -0500
Received: by mail-pg0-f66.google.com with SMTP id i5so38024537pgh.2
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 10:57:32 -0800 (PST)
In-Reply-To: <1caf1ffc-0f46-067e-0f0d-a93b408b4ffd@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

> On 2017年01月04日 00:48, John Fastabend wrote:
>> On 17-01-02 10:14 PM, Jason Wang wrote:
>>>
>>> On 2017年01月03日 06:30, John Fastabend wrote:
>>>> XDP programs can not consume multiple pages so we cap the MTU to
>>>> avoid this case. Virtio-net however only checks the MTU at XDP
>>>> program load and does not block MTU changes after the program
>>>> has loaded.
>>>>
>>>> This patch sets/clears the max_mtu value at XDP load/unload time.
>>>>
>>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>>> ---

[...]

>> OK so this logic is a bit too simply. When it resets the max_mtu I guess it
>> needs to read the mtu via
>>
>>     virtio_cread16(vdev, ...)
>>
>> or we may break the negotiated mtu.
> 
> Yes, this is a problem (even use ETH_MAX_MTU). We may need a method to notify
> the device about the mtu in this case which is not supported by virtio now.

Note this is not really a XDP specific problem. The guest can change the MTU
after init time even without XDP which I assume should ideally result in a
notification if the MTU is negotiated.

>>
>> As for capping it at GOOD_PACKET_LEN this has the nice benefit of avoiding any
>> underestimates in EWMA predictions because it appears min estimates are capped
>> at GOOD_PACKET_LEN via get_mergeable_buf_len().
> 
> This seems something misunderstanding here, I meant only use GOOD_PACKET_LEN for
> small buffer (which does not use EWMA).
> 

Yep I think its all cleared up now.

Thanks.
