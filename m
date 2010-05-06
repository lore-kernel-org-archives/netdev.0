From: Avi Kivity <avi@redhat.com>
Subject: Re: RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Thu, 06 May 2010 11:58:54 +0300
Message-ID: <4BE284CE.7010808@redhat.com>
References: <20100504230225.GP8323@vmware.com> <4BE1B217.80600@redhat.com> <20100505194417.GV8323@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: Pankaj Thakkar <pthakkar@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100505194417.GV8323@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/05/2010 10:44 PM, Pankaj Thakkar wrote:
> On Wed, May 05, 2010 at 10:59:51AM -0700, Avi Kivity wrote:
>    
>> Date: Wed, 5 May 2010 10:59:51 -0700
>> From: Avi Kivity<avi@redhat.com>
>> To: Pankaj Thakkar<pthakkar@vmware.com>
>> CC: "linux-kernel@vger.kernel.org"<linux-kernel@vger.kernel.org>,
>> 	"netdev@vger.kernel.org"<netdev@vger.kernel.org>,
>> 	"virtualization@lists.linux-foundation.org"
>>   <virtualization@lists.linux-foundation.org>,
>> 	"pv-drivers@vmware.com"<pv-drivers@vmware.com>,
>> 	Shreyas Bhatewara<sbhatewara@vmware.com>
>> Subject: Re: RFC: Network Plugin Architecture (NPA) for vmxnet3
>>
>> On 05/05/2010 02:02 AM, Pankaj Thakkar wrote:
>>      
>>> 2. Hypervisor control: All control operations from the guest such as programming
>>> MAC address go through the hypervisor layer and hence can be subjected to
>>> hypervisor policies. The PF driver can be further used to put policy decisions
>>> like which VLAN the guest should be on.
>>>
>>>        
>> Is this enforced?  Since you pass the hardware through, you can't rely
>> on the guest actually doing this, yes?
>>      
> We don't pass the whole VF to the guest. Only the BAR which is responsible for
> TX/RX/intr is mapped into guest space.

Does the SR/IOV spec guarantee that you will have such a separation?



>
>>
>>> We have reworked our existing Linux vmxnet3 driver to accomodate NPA by
>>> splitting the driver into two parts: Shell and Plugin. The new split driver is
>>>
>>>        
>> So the Shell would be the reworked or new bond driver, and Plugins would
>> be ordinary Linux network drivers.
>>      
> In NPA we do not rely on the guest OS to provide any of these services like
> bonding or PCI hotplug.

Well the Shell does some sort of bonding (there are two links and the 
shell selects which one to exercise) and some sort of hotplug.  Since 
the Shell is part of the guest OS, you do rely on it.

It's certainly simpler than PCI hotplug or ordinary bonding.

> We don't rely on the guest OS to unmap a VF and switch
> a VM out of passthrough. In a bonding approach that becomes an issue you can't
> just yank a device from underneath, you have to wait for the OS to process the
> request and switch from using VF to the emulated device and this makes the
> hypervisor dependent on the guest OS.

How can you unmap the VF without guest cooperation?  If you're executing 
Plugin code, you can't yank anything out.

Are plugins executed with preemption/interrupts disabled?

> Also we don't rely on the presence of all
> the drivers inside the guest OS (be it Linux or Windows), the ESX hypervisor
> carries all the plugins and the PF drivers and injects the right one as needed.
> These plugins are guest agnostic and the IHVs do not have to write plugins for
> different OS.
>    

What ISAs do those plugins support?

-- 
error compiling committee.c: too many arguments to function
