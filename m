From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 1/3] tuntap: rx batching
Date: Thu, 10 Nov 2016 20:45:02 -0800
Message-ID: <58254CCE.40505@gmail.com>
References: <1478677113-13126-1-git-send-email-jasowang@redhat.com>
 <20161109183259-mutt-send-email-mst@kernel.org>
 <c6cd619f-b9a6-784d-2c44-6106e64f5664@redhat.com>
 <20161111053048-mutt-send-email-mst@kernel.org> <58254654.4000501@gmail.com>
 <2b357b06-f749-5897-f882-aa3121e49e89@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2b357b06-f749-5897-f882-aa3121e49e89@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-10 08:28 PM, Jason Wang wrote:
> 
> 
> On 2016年11月11日 12:17, John Fastabend wrote:
>> On 16-11-10 07:31 PM, Michael S. Tsirkin wrote:
>>> >On Fri, Nov 11, 2016 at 10:07:44AM +0800, Jason Wang wrote:
>>>> >>
>>>> >>
>>>> >>On 2016年11月10日 00:38, Michael S. Tsirkin wrote:
>>>>> >>>On Wed, Nov 09, 2016 at 03:38:31PM +0800, Jason Wang wrote:
>>>>>> >>>>Backlog were used for tuntap rx, but it can only process 1
>>>>>> packet at
>>>>>> >>>>one time since it was scheduled during sendmsg() synchronously in
>>>>>> >>>>process context. This lead bad cache utilization so this patch
>>>>>> tries
>>>>>> >>>>to do some batching before call rx NAPI. This is done through:
>>>>>> >>>>
>>>>>> >>>>- accept MSG_MORE as a hint from sendmsg() caller, if it was set,
>>>>>> >>>>    batch the packet temporarily in a linked list and submit
>>>>>> them all
>>>>>> >>>>    once MSG_MORE were cleared.
>>>>>> >>>>- implement a tuntap specific NAPI handler for processing this
>>>>>> kind of
>>>>>> >>>>    possible batching. (This could be done by extending
>>>>>> backlog to
>>>>>> >>>>    support skb like, but using a tun specific one looks
>>>>>> cleaner and
>>>>>> >>>>    easier for future extension).
>>>>>> >>>>
>>>>>> >>>>Signed-off-by: Jason Wang<jasowang@redhat.com>
>>>>> >>>So why do we need an extra queue?
>>>> >>
>>>> >>The idea was borrowed from backlog to allow some kind of bulking
>>>> and avoid
>>>> >>spinlock on each dequeuing.
>>>> >>
>>>>> >>>   This is not what hardware devices do.
>>>>> >>>How about adding the packet to queue unconditionally, deferring
>>>>> >>>signalling until we get sendmsg without MSG_MORE?
>>>> >>
>>>> >>Then you need touch spinlock when dequeuing each packet.
>>> >
>> Random thought, I have a cmpxchg ring I am using for the qdisc work that
>> could possibly replace the spinlock implementation. I haven't figured
>> out the resizing API yet because I did not need it but I assume it could
>> help here and let you dequeue multiple skbs in one operation.
>>
>> I can post the latest version if useful or an older version is
>> somewhere on patchworks as well.
>>
>> .John
>>
>>
> 
> Look useful here, and I can compare the performance if you post.
> 
> A question is can we extend the skb_array to support that?
> 
> Thanks
> 

Sent out two RFC patches with the implementation, the first has been
running on my system for some time the second for multiple packets is
only lightly tested and that was awhile back.

.John
