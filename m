From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: eSwitch management
Date: Fri, 23 Apr 2010 12:00:18 -0700
Message-ID: <8A4C54B1-B5E5-461D-9699-38526B9CEBF4@qlogic.com>
References: <C7F64614.2ADDF%scofeldm@cisco.com>
 <DD92D5A8-1ECC-4440-BE81-ABDCC6847021@qlogic.com>
 <20100423162307.GI30693@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Scott Feldman <scofeldm@cisco.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:34188 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752902Ab0DWTAU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 15:00:20 -0400
In-Reply-To: <20100423162307.GI30693@x200.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 23, 2010, at 9:23 AM, Chris Wright wrote:

> * Anirban Chakraborty (anirban.chakraborty@qlogic.com) wrote:
>> 
>> On Apr 22, 2010, at 6:29 PM, Scott Feldman wrote:
>> 
>>> On 4/22/10 5:47 PM, "Scott Feldman" <scofeldm@cisco.com> wrote:
>>> 
>>>> On 4/22/10 4:16 PM, "Anirban Chakraborty" <anirban.chakraborty@qlogic.com>
>>>> wrote:
>>>> 
>>>>> I am following the discussions on iovnl patch closely. While it is going to
>>>>> take some time for iovnl patch to be reviewed and accepted, what would be the
>>>>> interim approach to manage the eswitch in NIC? We need to add support in
>>>>> qlcnic driver to configure the eswitch in our 10G NIC. Some of the things
>>>>> that
>>>>> we need to set to the switch are setting a port's VLAN, tx bandwidth etc. We
>>>>> would like to set these parameters for a bunch of ports at the start of the
>>>>> day and set it to the eswitch.
>>>> 
>>>> Are any of these settings covered in DCB?  (net/dcb/dcbnl.c).  Maybe you can
>>>> get a start there?  Not sure not knowing your device requirements.
>>> 
>>> Or maybe the RTM_SETLINK IFLA_VF_* ops in include/linux/if_link.h?  Those
>>> seem like what you're looking for.  I'm looking at moving iovnl here as well
>>> for port-profile.
>> 
>> It looks like ifla_vf_info does contain most of the data set. But if I use it, what NETLINK protocol family should I use in my driver to receive netlink messages? Do I need to create a private protocol family?
> 
> No, you don't need to use netlink in your driver.  You just need to fill
> in the relevant net_device_ops in your driver init.  Specifically:
> 
> *      SR-IOV management functions.
> * int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
> * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan, u8 qos);
> * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
> * int (*ndo_get_vf_config)(struct net_device *dev,
> *                          int vf, struct ifla_vf_info *ivf);
> 
> These are all operating on a VF indexed internally w/in the driver, so it's
> a little cumbersome to use from userspace.

These are all intended for VFs and are configureable from PF. However, in our case, there are multiple physical NIC function on a port which are configureable by the eswitch. So, what we are setting is essentially switch ports, rather than configuring any setting on the physical functions. If netlink doesn't fly, is sysfs going to work? If we allocate a buffer and fill it up with user space tools that the driver grabs it and does the configuration itself?  

thanks,
Anirban


