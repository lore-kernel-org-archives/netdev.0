From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 17:27:04 +0300
Message-ID: <49D4CB38.5030205@redhat.com>
References: <49D469D2020000A100045FA1@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: anthony@codemonkey.ws, andi@firstfloor.org,
	herbert@gondor.apana.org.au, Gregory Haskins <GHaskins@novell.com>,
	Peter Morreale <PMorreale@novell.com>, rusty@rustcorp.com.au,
	agraf@suse.de, kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick Mullaney <pmullaney@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D473EA020000C700056627@lucius.provo.novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick Mullaney wrote:
> On Thu, 2009-04-02 at 16:27 +0300, Avi Kivity wrote:
>
>   
>> virtio is a stable ABI.
>>
>>     
>>> However, theres still the possibility we can make this work in an ABI
>>> friendly way with cap-bits, or other such features.  For instance, the
>>> virtio-net driver could register both with pci and vbus-proxy and
>>> instantiate a device with a slightly different ops structure for each or
>>> something.  Alternatively we could write a host-side shim to expose vbus
>>> devices as pci devices or something like that.
>>>   
>>>       
>> Sounds complicated...
>>
>>     
>
> IMO, it doesn't sound anymore complicated than making virtio support the
> concepts already provided by vbus/venet-tap driver. Isn't there already
> precedent for alternative approaches co-existing and having the users
> decide which is the most appropriate for their use case? Switching
> drivers in order to improve latency for a certain class of applications
> would seem like something latency sensitive users would be more than
> willing to do. I'd like to point out 2 things. Greg has offered help
> in moving virtio into the vbus infrastructure. The vbus infrastructure
> is a large part of what is being proposed here.
>   

vbus (if I understand it right) is a whole package of things:

- a way to enumerate, discover, and manage devices

That part duplicates PCI and it would be pretty hard to convince me we 
need to move to something new.  virtio-pci (a) works, (b) works on Windows.

- a different way of doing interrupts

Again, the need to paravirtualize kills this on Windows (I think).

- a different ring layout, and splitting notifications from the ring

I don't see the huge win here

- placing the host part in the host kernel

Nothing vbus-specific here.

Switching drivers is unfortunately not easy on Linux as you need a new 
kernel; it's easier on Windows once you have the drivers written.

-- 
error compiling committee.c: too many arguments to function

