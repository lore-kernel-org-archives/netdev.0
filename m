From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for	vbus_driver
 objects
Date: Tue, 18 Aug 2009 14:54:46 +0300
Message-ID: <4A8A9686.1070401@redhat.com>
References: <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <20090818095313.GC13878@redhat.com> <4A8A7BB9.2020906@redhat.com> <20090818100945.GD13878@redhat.com> <4A8A7EE5.6090209@redhat.com> <20090818102840.GF13878@redhat.com> <4A8A8631.1040006@redhat.com> <20090818110708.GG13878@redhat.com> <4A8A8D6D.9040909@redhat.com> <20090818114914.GA17721@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090818114914.GA17721@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/18/2009 02:49 PM, Michael S. Tsirkin wrote:
>
>> The host kernel sees a hypercall vmexit.  How does it know if it's a
>> nested-guest-to-guest hypercall or a nested-guest-to-host hypercall?
>> The two are equally valid at the same time.
>>      
> Here is how this can work - it is similar to MSI if you like:
> - by default, the device uses pio kicks
> - nested guest driver can enable hypercall capability in the device,
>    probably with pci config cycle
> - guest userspace (hypervisor running in guest) will see this request
>    and perform pci config cycle on the "real" device, telling it to which
>    nested guest this device is assigned
>    

So far so good.

> - host userspace (hypervisor running in host) will see this.
>    it now knows both which guest the hypercalls will be for,
>    and that the device in question is an emulated one,
>    and can set up kvm appropriately
>    

No it doesn't.  The fact that one device uses hypercalls doesn't mean 
all hypercalls are for that device.  Hypercalls are a shared resource, 
and there's no way to tell for a given hypercall what device it is 
associated with (if any).

>> The host knows whether the guest or nested guest are running.  If the
>> guest is running, it's a guest-to-host hypercall.  If the nested guest
>> is running, it's a nested-guest-to-guest hypercall.  We don't have
>> nested-guest-to-host hypercalls (and couldn't unless we get agreement on
>> a protocol from all hypervisor vendors).
>>      
> Not necessarily. What I am saying is we could make this protocol part of
> guest paravirt driver. the guest that loads the driver and enables the
> capability, has to agree to the protocol. If it doesn't want to, it does
> not have to use that driver.
>    

It would only work for kvm-on-kvm.

-- 
error compiling committee.c: too many arguments to function

