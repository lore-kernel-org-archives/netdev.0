From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [PATCH net-next] sysfs: add entry to indicate network
 interfaces with random MAC address
Date: Wed, 21 Jul 2010 11:43:19 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755F184620A@orsmsx508.amr.corp.intel.com>
References: <20100721150732.GR7497@gospo.rdu.redhat.com>
 <20100721102816.4bef5ada@nehalam>
 <20100721.103249.107094774.davem@davemloft.net>
 <201007211129.48288.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"harald@redhat.com" <harald@redhat.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Casey Leedom <leedom@chelsio.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201007211129.48288.leedom@chelsio.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Casey Leedom [mailto:leedom@chelsio.com]
>Sent: Wednesday, July 21, 2010 11:30 AM
>To: David Miller
>Cc: shemminger@vyatta.com; andy@greyhouse.net; harald@redhat.com;
>bhutchings@solarflare.com; sassmann@redhat.com; netdev@vger.kernel.org;
>linux-kernel@vger.kernel.org; gospo@redhat.com; Rose, Gregory V; Duyck,
>Alexander H
>Subject: Re: [PATCH net-next] sysfs: add entry to indicate network
>interfaces with random MAC address
>
>| From: David Miller <davem@davemloft.net>
>| Date: Wednesday, July 21, 2010 10:32 am
>|
>| From: Stephen Hemminger <shemminger@vyatta.com>
>| Date: Wed, 21 Jul 2010 10:28:16 -0700
>|
>| > IMHO no local assigned address should be used by udev. The cxgb4
>driver
>| > should be using random value.
>| >
>| > Does anyone have an example of locally assigned address that has
>| > persistence so that udev could use it.
>|
>| The cxgb4 vf addresses are not random because they are fetched from
>the
>| card's NVRAM/EEPROM/firmware/whatever and thus are persistent.
>|
>| We definitely want udev to use persistent rules for them.
>|
>| This whole issue only exists because of the Intel VF case, where it
>| lacks persistent addresses but somehow we want to assign persistent
>| names to it's VF interfaces.
>
>  Yes, we _explicitly_ wanted to have persistent MAC Addresses for our
>PCI-E SR-
>IOV Virtual Functions for a whole raft of reasons.  The two most
>important were:
>
> 1. Linux' model for persistent device naming today seems to be
>    oriented around persistent network device addresses.
>
> 2. Lots of data centers use MAC addresses for things like DHCP/BOOTP,
>    security/filtering, etc.
>
>Our design goal was to look as much like a normal Ethernet MAC as
>possible in
>order to reduce the need for software/behavior changes.

I'm curious, what happens when the VM using the VF migrates to a new machine and has another VF assigned to with a different MAC address?

Intel's view of things is that we don't use persistent MAC addresses in our VFs because the MAC address belongs to the VM and when it migrates it's going to want to use another VF with the same MAC address.  If they're persistent I'm wondering how that can be done.

This discussion has come about because some folks want to use the VF in the Host VMM.  The original design goal for Intel was that VFs would be assigned to VMs and that VMM vendors would want to assign MAC addresses with their own assigned OUI's.

- Greg
