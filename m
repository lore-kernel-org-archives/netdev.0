From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/1] Defer skb allocation for both mergeable buffers
	and big packets in virtio_net
Date: Tue, 24 Nov 2009 18:04:39 +0200
Message-ID: <20091124160439.GC6737@redhat.com>
References: <1258697745.7416.20.camel@localhost.localdomain> <200911231138.30755.rusty@rustcorp.com.au> <1258992421.5022.19.camel@localhost.localdomain> <200911240854.24054.rusty@rustcorp.com.au> <20091124113754.GB2405@redhat.com> <4B0BEF70.5070104@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Shirley Ma <mashirle@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hollis Blanchard <hollisb@us.ibm.com>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B0BEF70.5070104@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 24, 2009 at 08:36:32AM -0600, Anthony Liguori wrote:
> Michael S. Tsirkin wrote:
>> On Tue, Nov 24, 2009 at 08:54:23AM +1030, Rusty Russell wrote:
>>   
>>> On Tue, 24 Nov 2009 02:37:01 am Shirley Ma wrote:
>>>     
>>>>>> +             skb = (struct sk_buff *)buf;
>>>>>>           
>>>>> This cast is unnecessary, but a comment would be nice:
>>>>>         
>>>> Without this cast there is a compile warning.       
>>> Hi Shirley,
>>>
>>>    Looks like buf is a void *, so no cast should be necessary.  But I could
>>> be reading the patch wrong.
>>>
>>>     
>>>>> However, I question whether making it 16 byte is the right thing: the
>>>>> ethernet header is 14 bytes long, so don't we want 8 bytes of padding?
>>>>>         
>>>> Because in QEMU it requires 10 bytes header in a separately, so one page
>>>> is used to share between virtio_net_hdr header which is 10 bytes head
>>>> and rest of data. So I put 6 bytes offset here between two buffers. I
>>>> didn't look at the reason why a seperate buf is used for virtio_net_hdr
>>>> in QEMU.
>>>>       
>>> It's a qemu bug.  It insists the header be an element in the scatterlist by
>>> itself.  Unfortunately we have to accommodate it.
>>>     
>>
>> We do?  Let's just fix this?
>>   
>
> So does lguest.

It does? All I see it doing is writev/readv,
and this passes things to tap which handles
this correctly.


>  It's been that way since the beginning.  Fixing this  
> would result in breaking older guests.

If you look at my patch, it handles old guests just fine :).

> We really need to introduce a feature bit if we want to change this.

I am not sure I agree: we can't add feature bits
for all bugs, can we?

-- 
MST
