From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [PATCH net-next] sysfs: add entry to indicate network
 interfaces with random MAC address
Date: Wed, 21 Jul 2010 12:02:17 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755F1846247@orsmsx508.amr.corp.intel.com>
References: <201007211129.48288.leedom@chelsio.com>
	<43F901BD926A4E43B106BF17856F0755F184620A@orsmsx508.amr.corp.intel.com>
	<20100721.114851.200597269.davem@davemloft.net>
 <20100721.115023.69942880.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "leedom@chelsio.com" <leedom@chelsio.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"harald@redhat.com" <harald@redhat.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100721.115023.69942880.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Wednesday, July 21, 2010 11:50 AM
>To: Rose, Gregory V
>Cc: leedom@chelsio.com; shemminger@vyatta.com; andy@greyhouse.net;
>harald@redhat.com; bhutchings@solarflare.com; sassmann@redhat.com;
>netdev@vger.kernel.org; linux-kernel@vger.kernel.org; gospo@redhat.com;
>Duyck, Alexander H
>Subject: Re: [PATCH net-next] sysfs: add entry to indicate network
>interfaces with random MAC address
>
>From: David Miller <davem@davemloft.net>
>Date: Wed, 21 Jul 2010 11:48:51 -0700 (PDT)
>
>> You could do things like have the PF controller use the root
>filesystem
>> ID label to construct the VF's MAC address, or something like that.
>
>And here I of course mean the root filesystem of the guest the VF will
>be given to.

I suppose you could do that but then the VM is going to have to be allowed to set its own MAC address.  There is a lot of opposition and concern about allowing VMs to set their own MAC address.

Then there's also support in the kernel now for assigning VF MAC and VLAN via the iproute2 package "ip link" commands.  The administrative SW that controls VMs should be assigning MAC addresses to VFs as needed.  When the VF is de-assigned from the guest because the VM is migrating then the administrative SW can assign another VF to the VM at the migration target machine and assign the same MAC address then.  This way it is all done administratively from the (supposedly) secure host VMM domain and we're not allowing VMs to set their own MAC address.

Ultimately I think I agree that some sort of approach such as you and others have been suggesting should be taken.  I'm agnostic about which one because my view of how things should work is a bit different.  But if the community thinks that finding some way to set a persistent MAC address for a VF is useful then I'd more than happy to make sure our drivers support that also.

As soon as it is decided what that is of course.

;-)

- Greg
