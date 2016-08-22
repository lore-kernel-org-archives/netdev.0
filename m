From: Gerard Garcia <ggarcia@abra.uab.cat>
Subject: Re: [PATCH v2 0/3] VSOCK: vsockmon virtual device to monitor AF_VSOCK
 sockets.
Date: Mon, 22 Aug 2016 12:48:05 +0200
Message-ID: <6f0e18a8-45df-db93-660a-e3c6bf85c2b2@deic.uab.cat>
References: <20160813102154.14338-1-ggarcia@deic.uab.cat>
 <20160814231538.jihsj54ft7aftvdf@redhat.com>
 <20160815151326.GE3598@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stefan Hajnoczi <stefanha@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36673 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754949AbcHVKsI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 06:48:08 -0400
Received: by mail-wm0-f65.google.com with SMTP id i138so12798363wmf.3
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 03:48:07 -0700 (PDT)
In-Reply-To: <20160815151326.GE3598@stefanha-x1.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2016 05:13 PM, Stefan Hajnoczi wrote:
> On Mon, Aug 15, 2016 at 02:15:38AM +0300, Michael S. Tsirkin wrote:
>> On Sat, Aug 13, 2016 at 12:21:51PM +0200, ggarcia@abra.uab.cat wrote:
>>> From: Gerard Garcia <ggarcia@deic.uab.cat>
>>>
>>> This patch applies over the mst vhost git repository:
>>> http://git.kernel.org/cgit/linux/kernel/git/mst/vhost.git
>>
>> So I do like where this is going, but it gives me pause
>> that there's a global list of taps, where all sockets
>> seem to multicast to them all.
>>
>> In particular, this won't play well with things
>> like containers.
>
> vsock currently has no network namespace support.  I agree that the tap
> instances should be per-namespace when we add namespace support.
>
>> As each socket is bound to a physical device, how about binding
>> the monitor there as well?
>
> Sockets aren't bound to physical devices, they are bound globally in the
> af_vsock.ko module.  The module currently doesn't allow multiple
> instances (you cannot have multiple VMCI or virtio transports).
>
>> Only sockets from this device
>> would do the forwarding, and only one monitor per
>> device would be supported.
>>
>> In a sense this will make it more like macvtap than tap.
>
> Restricting the number of monitors could make userspace cumbersome.
> Imagine two scripts that want to capture packets.  The two scripts have
> no knowledge of each other and create their own vsockmon interfaces.  If
> we restrict vsockmon to just 1 interface then users need to agree on
> sharing just 1 vsockmon interface.  I don't think this is beneficial.
>
> So I think this global list is acceptable until we introduce network
> namespace support.  At that point it will become per-namespace.
>

Sorry, I was out last week.

I don't have much to add to what Stefan said. I agree that when vsock 
introduces namespace support it will be necessary to have monitors 
divided per-namespace. Right now, if only one af_vsock instance is 
allowed, I think it makes sense to have a global list of taps.

Gerard
