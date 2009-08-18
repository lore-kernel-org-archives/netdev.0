From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for	vbus_driver
 objects
Date: Tue, 18 Aug 2009 13:45:05 +0300
Message-ID: <4A8A8631.1040006@redhat.com>
References: <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <20090818095313.GC13878@redhat.com> <4A8A7BB9.2020906@redhat.com> <20090818100945.GD13878@redhat.com> <4A8A7EE5.6090209@redhat.com> <20090818102840.GF13878@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758661AbZHRKp2@vger.kernel.org>
In-Reply-To: <20090818102840.GF13878@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/18/2009 01:28 PM, Michael S. Tsirkin wrote:
>
>> Suppose a nested guest has two devices.  One a virtual device backed by
>> its host (our guest), and one a virtual device backed by us (the real
>> host), and assigned by the guest to the nested guest.  If both devices
>> use hypercalls, there is no way to distinguish between them.
>>      
> Not sure I understand. What I had in mind is that devices would have to
> either use different hypercalls and map hypercall to address during
> setup, or pass address with each hypercall.  We get the hypercall,
> translate the address as if it was pio access, and know the destination?
>    

There are no different hypercalls.  There's just one hypercall 
instruction, and there's no standard on how it's used.  If a nested call 
issues a hypercall instruction, you have no idea if it's calling a 
Hyper-V hypercall or a vbus/virtio kick.

You could have a protocol where you register the hypercall instruction's 
address with its recipient, but it quickly becomes a tangled mess.  And 
for what?  pio and hypercalls have the same performance characteristics.

-- 
error compiling committee.c: too many arguments to function
