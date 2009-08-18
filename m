From: "Gregory Haskins" <GHaskins@novell.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model
	 for	vbus_drive
Date: Tue, 18 Aug 2009 06:11:35 -0600
Message-ID: <4A8A62370200005A000528DF@sinclair.provo.novell.com>
References: <4A8A622E0200005A000528DC@sinclair.provo.novell.com>
 <4A8A62370200005A000528DF@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <mingo@elte.hu>, <gregory.haskins@gmail.com>,
	<alacrityvm-devel@lists.sourceforge.net>, <kvm@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <avi@redhat.com>, <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758791AbZHRMLi@vger.kernel.org>
In-Reply-To: <4A8A62370200005A000528DF@sinclair.provo.novell.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for the toppost.  Still not at the office.

I just wanted to add that we've already been through this disussion once.  (Search "haskins hypercall lkml" on google and I'm sure you are bound to see hits.

The fact is: the original vbus was designed with hypercalls, and it drew much of these same critisims.  In the end, hypercalls are only marginally faster than PIO (iirc, 450ns faster, and shrinking), so we decided that it was not worth further discussion at the time.

A better solution is probably PIOoHC, so that you retain the best properties of both.  The only problem with the entire PIOx approach is that its x86 specific, but that is an entirely different thread.

Hth
-greg 
 
-----Original Message-----
From: Avi Kivity <avi@redhat.com>
Cc: Gregory Haskins <GHaskins@novell.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Gregory Haskins <gregory.haskins@gmail.com>
Cc:  <alacrityvm-devel@lists.sourceforge.net>
To: Michael S. Tsirkin <mst@redhat.com>
Cc:  <kvm@vger.kernel.org>
Cc:  <linux-kernel@vger.kernel.org>
Cc:  <netdev@vger.kernel.org>

Sent: 8/18/2009 5:54:46 AM
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for	vbus_driver objects

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
