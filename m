From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Sat, 15 Aug 2009 14:15:48 -0500
Message-ID: <4A870964.9090408@codemonkey.ws>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090815103243.GA26749@elte.hu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
> * Gregory Haskins <ghaskins@novell.com> wrote:
>
>   
>> This will generally be used for hypervisors to publish any host-side
>> virtual devices up to a guest.  The guest will have the opportunity
>> to consume any devices present on the vbus-proxy as if they were
>> platform devices, similar to existing buses like PCI.
>>
>> Signed-off-by: Gregory Haskins <ghaskins@novell.com>
>> ---
>>
>>  MAINTAINERS                 |    6 ++
>>  arch/x86/Kconfig            |    2 +
>>  drivers/Makefile            |    1 
>>  drivers/vbus/Kconfig        |   14 ++++
>>  drivers/vbus/Makefile       |    3 +
>>  drivers/vbus/bus-proxy.c    |  152 +++++++++++++++++++++++++++++++++++++++++++
>>  include/linux/vbus_driver.h |   73 +++++++++++++++++++++
>>  7 files changed, 251 insertions(+), 0 deletions(-)
>>  create mode 100644 drivers/vbus/Kconfig
>>  create mode 100644 drivers/vbus/Makefile
>>  create mode 100644 drivers/vbus/bus-proxy.c
>>  create mode 100644 include/linux/vbus_driver.h
>>     
>
> Is there a consensus on this with the KVM folks? (i've added the KVM 
> list to the Cc:)
>   

I'll let Avi comment about it from a KVM perspective but from a QEMU 
perspective, I don't think we want to support two paravirtual IO 
frameworks.  I'd like to see them converge.  Since there's an install 
base of guests today with virtio drivers, there really ought to be a 
compelling reason to change the virtio ABI in a non-backwards compatible 
way.  This means convergence really ought to be adding features to virtio.

On paper, I don't think vbus really has any features over virtio.  vbus 
does things in different ways (paravirtual bus vs. pci for discovery) 
but I think we're happy with how virtio does things today.

I think the reason vbus gets better performance for networking today is 
that vbus' backends are in the kernel while virtio's backends are 
currently in userspace.  Since Michael has a functioning in-kernel 
backend for virtio-net now, I suspect we're weeks (maybe days) away from 
performance results.  My expectation is that vhost + virtio-net will be 
as good as venet + vbus.  If that's the case, then I don't see any 
reason to adopt vbus unless Greg things there are other compelling 
features over virtio.

Regards,

Anthony Liguori

> 	Ingo
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

