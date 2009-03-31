From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 14/17] kvm: add a reset capability
Date: Tue, 31 Mar 2009 23:18:35 +0300
Message-ID: <49D27A9B.9030703@redhat.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <20090331184400.28333.50396.stgit@dev.haskins.net> <49D26D8B.7020201@redhat.com> <49D276E5.6000000@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D276E5.6000000@novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
> Avi Kivity wrote:
>   
>> Gregory Haskins wrote:
>>     
>>> We need a way to detect if a VM is reset later in the series, so lets
>>> add a capability for userspace to signal a VM reset down to the kernel.
>>>   
>>>       
>> How do you handle the case of a guest calling kexec to load a new
>> kernel?  Or is that not important for your use case?
>>
>>     
>
> Hmm..I had not considered this.  Any suggestions on ways to detect it?
>
>   

Best would be not to detect it; it's tying global events into a device.  
Instead, have a reset command for your device and have the driver issue 
it on load and unload.

btw, reset itself would be better controlled from userspace; qemu knows 
about resets and can reset vbus devices directly instead of relying on 
kvm to reset them.  This decouples the two code bases a bit.  This is 
what virtio does.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

