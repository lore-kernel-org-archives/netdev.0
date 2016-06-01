From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [v2 PATCH 1/2] macvlan: Fix potential use-after free for broadcasts
Date: Wed, 1 Jun 2016 16:36:53 -0700
Message-ID: <CAM_iQpU3qnV6Zf5bCKMM6smSsDVD9Jeb1VffCi7RaCKsHREHdw@mail.gmail.com>
References: <20160526234433.GU8402@wantstofly.org> <20160530081752.GA4956@gondor.apana.org.au>
 <20160530082828.GB5106@gondor.apana.org.au> <20160531.140713.2187659962450926738.davem@davemloft.net>
 <20160601034218.GA31335@gondor.apana.org.au> <20160601034300.GB31335@gondor.apana.org.au>
 <CAM_iQpVbo7cfuura=FC4gJimnjLx1gy=4HWe9QmSwzEZT9254Q@mail.gmail.com> <20160601042719.GA31691@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Patrick McHardy <kaber@trash.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jiri Pirko <jpirko@redhat.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:33142 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbcFAXhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 19:37:13 -0400
Received: by mail-yw0-f172.google.com with SMTP id h19so34301498ywc.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 16:37:13 -0700 (PDT)
In-Reply-To: <20160601042719.GA31691@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 31, 2016 at 9:27 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Tue, May 31, 2016 at 09:19:37PM -0700, Cong Wang wrote:
>>
>> Hmm, why could this happen? The upper device should be linked
>> with the lower device, where a refcount is already held.
>> Also, the work is cancelled in ->uninit().
>
> Of course it can happen.  We are talking about the source macvlan
> device that we just looked up using the Ethernet address.  That
> device has nothing to do with the packet now so it may be deleted
> at any time.
>
> We do flush the work but only when the all macvlan devices on a
> port have been deleted.  Perhaps you're confusing the source
> device with vlan->lowerdev which is confusingly the actual
> hardware device?

I thought all the on-flying packets are waited by synchronize_net()
during the removal of any of these devices. But since you moved
them to a workqueue, aka process context, so I think it won't
work any more.

Your patch makes sense to me now. :)

Thanks!
