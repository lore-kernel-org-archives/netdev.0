From: Avi Kivity <avi@redhat.com>
Subject: Re: copyless virtio net thoughts?
Date: Fri, 06 Feb 2009 16:55:40 +0200
Message-ID: <498C4F6C.4070402@redhat.com>
References: <20090205020732.GA27684@sequoia.sous-sol.org> <498ADD73.3060906@redhat.com> <20090206054054.GA4824@gondor.apana.org.au> <498BF8ED.8090208@redhat.com> <20090206091904.GA6645@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@sous-sol.org>, Arnd Bergmann <arnd@arndb.de>,
	Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090206091904.GA6645@gondor.apana.org.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Feb 06, 2009 at 10:46:37AM +0200, Avi Kivity wrote:
>   
>> The guest's block layer is copyless.  The host block layer is -><- this  
>> far from being copyless -- all we need is preadv()/pwritev() or to  
>> replace our thread pool implementation in qemu with linux-aio.   
>> Everything else is copyless.
>>
>> Since we are actively working on this, expect this limitation to  
>> disappear soon.
>>     
>
> Great, when that happens I'll promise to revisit zero-copy transmit :)
>
>   

I was hoping to get some concurrency here, but okay.

>> I support this, but it should be in addition to copylessness, not on its  
>> own.
>>     
>
> I was talking about it in the context of zero-copy receive, where
> you mentioned that the virtio/kvm copy may not occur on the CPU of
> the guest's copy.
>
> My point is that using multiqueue you can avoid this change of CPU.
>
> But yeah I think zero-copy receive is much more useful than zero-
> copy transmit at the moment.  Although I'd prefer to wait for
> you guys to finish the block layer work before contemplating
> pushing the copy on receive into the guest :)
>
>   

We'll get the block layer done soon, so it won't be a barrier.

>> - many guests will not support multiqueue
>>     
>
> Well, these guests will suck both on baremetal and in virtualisation,
> big deal :) Multiqueue at 10GbE speeds and above is simply not an
> optional feature.
>   

Each guest may only use a part of the 10Gb/s bandwidth, if you have 10 
guests each using 1Gb/s, then we should be able to support this without 
multiqueue in the guests.


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

