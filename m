From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: eSwitch management
Date: Fri, 23 Apr 2010 14:08:29 -0700
Message-ID: <193C9C72-488F-4543-9BC1-F9938F189E91@qlogic.com>
References: <C7F64614.2ADDF%scofeldm@cisco.com>
 <DD92D5A8-1ECC-4440-BE81-ABDCC6847021@qlogic.com>
 <20100423162307.GI30693@x200.localdomain>
 <8A4C54B1-B5E5-461D-9699-38526B9CEBF4@qlogic.com>
 <20100423194455.GA3843@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Scott Feldman <scofeldm@cisco.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:33089 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757520Ab0DWVIc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 17:08:32 -0400
In-Reply-To: <20100423194455.GA3843@x200.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 23, 2010, at 12:44 PM, Chris Wright wrote:

> * Anirban Chakraborty (anirban.chakraborty@qlogic.com) wrote:
>> On Apr 23, 2010, at 9:23 AM, Chris Wright wrote:
>>> * Anirban Chakraborty (anirban.chakraborty@qlogic.com) wrote:
>>>> It looks like ifla_vf_info does contain most of the data set. But if I use it, what NETLINK protocol family should I use in my driver to receive netlink messages? Do I need to create a private protocol family?
>>> 
>>> No, you don't need to use netlink in your driver.  You just need to fill
>>> in the relevant net_device_ops in your driver init.  Specifically:
>>> 
>>> *      SR-IOV management functions.
>>> * int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
>>> * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan, u8 qos);
>>> * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
>>> * int (*ndo_get_vf_config)(struct net_device *dev,
>>> *                          int vf, struct ifla_vf_info *ivf);
>>> 
>>> These are all operating on a VF indexed internally w/in the driver, so it's
>>> a little cumbersome to use from userspace.
>> 
>> These are all intended for VFs and are configureable from PF.
> 
> Yes, and while the set of callbacks can change, they are always tied to
> some net_device (typically the PF) that knows how to make hardware
> settings on behalf of a VF.
> 
>> However, in our case, there are multiple physical NIC function on a
>> port which are configureable by the eswitch.
> 
> Is there a PCI function that represents the switch?  Or a special PCI
> NIC function that has VEB mgmt plane access?  And do you have examples
> of configuration that you'll do here?
There is no PCI function that represents the switch. However, one of the NIC functions can act as a privileged function to configure the eswitch. Typically the first NIC function that is enumerated in the bus manages the eswitch. Typical configurations would be to set tx bandwidth, VLAN ID, MAC address, promiscuous mode setting for each of these ports at the start of the day. This is useful in virtualization scenario where we can do PCI passthru of the functions to the guest and these settings for the guest are configured via the driver in the host.

<snip>
> 
> One idea that has been discussed in the past is to create essentially
> a pluggable set of bridge_ops.  The first step would be purely internal
> shuffling, to make the existing sw bridge code go through the bridge_ops.
> The second step would be making your driver for whichever PCI function
> you have that supports managing the bridge create a net_device which is
> a bridge during driver init.  And now normal brctl can call into your
> VEB via the bridge_ops callbacks. </handwave>
> 
I liked the idea of iovnl as it works by utilizing port profile. That way the eswitch can be configured with the same port profile that a vswitch in a hypervisor has.

thanks,
Anirban




