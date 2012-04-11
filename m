From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v1 2/7] net: addr_list: add exclusive dev_uc_add
 and dev_mc_add
Date: Wed, 11 Apr 2012 07:46:07 -0700
Message-ID: <4F85992F.8010708@intel.com>
References: <20120409215419.3288.50790.stgit@jf-dev1-dcblab>  <20120409220023.3288.59939.stgit@jf-dev1-dcblab> <1334115190.7150.365.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, stephen.hemminger@vyatta.com, davem@davemloft.net,
	hadi@cyberus.ca, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gregory.v.rose@intel.com,
	krkumar2@in.ibm.com, sri@us.ibm.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52539 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754502Ab2DKOqI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 10:46:08 -0400
In-Reply-To: <1334115190.7150.365.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/2012 8:33 PM, Ben Hutchings wrote:
> On Mon, 2012-04-09 at 15:00 -0700, John Fastabend wrote:
>> This adds a dev_uc_add_excl() and dev_mc_add_excl() calls
>> similar to the original dev_{uc|mc}_add() except it sets
>> the global bit and returns -EEXIST for duplicat entires.
>>
>> This is useful for drivers that support SR-IOV, macvlan
>> devices and any other devices that need to manage the
>> unicast and multicast lists.
> [...]
>> +/**
>> + *	dev_mc_add_excl - Add a global secondary multicast address
>> + *	@dev: device
>> + *	@addr: address to add
>> + */
>> +int dev_mc_add_excl(struct net_device *dev, unsigned char *addr)
>> +{
>> +	struct netdev_hw_addr *ha;
>> +	int err;
>> +
>> +	netif_addr_lock_bh(dev);
>> +	list_for_each_entry(ha, &dev->mc.list, list) {
>> +		if (!memcmp(ha->addr, addr, dev->addr_len) &&
>> +		    ha->type == NETDEV_HW_ADDR_T_UNICAST) {
>> +			err = -EEXIST;
>> +			goto out;
>> +		}
>> +	}
>> +	err = __hw_addr_create_ex(&dev->mc, addr, dev->addr_len,
>> +				  NETDEV_HW_ADDR_T_UNICAST, true);
> [...]
> 
> The address types are wrong.  But do we even need this function yet?
> 
> Ben.
> 

macvlan wants to manage multicast addresses as well. Good catch thanks.

.John
