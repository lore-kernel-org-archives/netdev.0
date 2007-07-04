From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 2/4] net: use numa_node in net_devcice->dev instead of
 parent
Date: Wed, 04 Jul 2007 13:04:10 +0200
Message-ID: <468B7EAA.2040903@s5r6.in-berlin.de>
References: <20070703143407.7e4232f8@freepuppy.localdomain.hemminger.net>	<200707031730.51677.yinghai.lu@sun.com>	<20070704085120.GB19515@infradead.org> <20070704.033530.105423846.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, Yinghai.Lu@Sun.COM,
	shemminger@linux-foundation.org, akpm@linux-foundation.org,
	ak@suse.de, greg@kroah.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760913AbXGDLEf@vger.kernel.org>
In-Reply-To: <20070704.033530.105423846.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Christoph Hellwig <hch@infradead.org>
> Date: Wed, 4 Jul 2007 09:51:20 +0100
> 
>> On Tue, Jul 03, 2007 at 05:30:51PM -0700, Yinghai Lu wrote:
...
>> >  struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
>> >  		unsigned int length, gfp_t gfp_mask)
>> >  {
>> > -	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
>> > +	int node = dev_to_node(&dev->dev);
>> 
>> This looks wrong to me unless the device model has once again changed
>> silently.  When I wrote this code &dev->dev was a device allocated
>> as part of the netdevice and the parent is the pci (or whatever) device
>> that has the node information.
> 
> Correct, this change is completely bogus.

I've got a question from a network driver writer's perspective:  In
drivers which sit on top of a midlayer/ multi-protocol infrastructure,
should dev->dev.parent be the lowlevel's pci_dev.dev or the midlayer's
whatever_abstracted_dev.dev?

(Example:  eth1394 network driver sits on top of ieee1394 = FireWire
midlayer, this sits on top of ohci1394 = PCI driver for FireWire
controllers.)

I guess it should be the lowlevel's pci_dev.dev, unless the midlayer
cares to set
  set_dev_node(&midlayer_dev.dev, dev_to_node(midlayer_dev.dev.parent));

And either way, for full effect of NUMA awareness in the highlevel
network driver, the midlayer should be NUMA aware too...
-- 
Stefan Richter
-=====-=-=== -=== --=--
http://arcgraph.de/sr/
