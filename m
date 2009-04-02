From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 12:02:09 +0300
Message-ID: <49D47F11.6070400@redhat.com>
References: <20090402085253.GA29932@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ghaskins@novell.com, anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:44971 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932868AbZDBJCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 05:02:47 -0400
In-Reply-To: <20090402085253.GA29932@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Avi Kivity <avi@redhat.com> wrote:
>   
>> virtio is already non-kvm-specific (lguest uses it) and non-pci-specific 
>> (s390 uses it).
>>     
>
> I think Greg's work shows that putting the backend in the kernel
> can dramatically reduce the cost of a single guest->host transaction.
> I'm sure the same thing would work for virtio too.
>   

Virtio suffers because we've had no notification of when a packet is 
actually submitted.  With the notification, the only difference should 
be in the cost of a kernel->user switch, which is nowhere nearly as 
dramatic.

>> If you have a good exit mitigation scheme you can cut exits by a factor 
>> of 100; so the userspace exit costs are cut by the same factor.  If you 
>> have good copyless networking APIs you can cut the cost of copies to 
>> zero (well, to the cost of get_user_pages_fast(), but a kernel solution 
>> needs that too).
>>     
>
> Given the choice of having to mitigate or not having the problem
> in the first place, guess what I would prefer :)
>   

There is no choice.  Exiting from the guest to the kernel to userspace 
is prohibitively expensive, you can't do that on every packet.

-- 
error compiling committee.c: too many arguments to function

