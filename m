From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH 0/2][RFC] virtio_net: MAC filtering
Date: Fri, 09 Jan 2009 19:54:12 +0200
Message-ID: <49678F44.4090900@redhat.com>
References: <1231351559.7109.128.camel@lappy> <4964F11B.7020509@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alex Williamson <alex.williamson@hp.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	kvm <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4964F11B.7020509@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anthony Liguori wrote:
> Alex Williamson wrote:
>> This series builds on some of the patches Mark McLoughlin has sent out
>> recently, so likely won't apply to any current trees until those get
>> upstream.  The goal is to enable MAC filtering at the kvm/qemu level for
>> virtio-net packets.  Promiscuous and allmulti mode are handled by adding
>> bits to Mark's proposed status field.  I also add a 16 entry MAC table
>> for additional unicast and multicast addresses to filter.  If this looks
>> reasonable, I'll follow-up with VLAN filtering.
>>
>> As noted in the RFC thread adding the kvm/qemu backing, this does
>> increase the size of the virtio-net device I/O port space, up to 1kB
>> with PCI rounding if we add a 4k entry VLAN bitmap.  A 64 device limit
>> is still pretty high for a VM, but maybe we should think about adding
>> MMIO space for virtio-pci.  Thanks,
>>   
>
> I'm not quite sure the best way to address this.  Maybe another 
> control queue for sending commands to control this sort of stuff?  
> What are your thoughts Rusty?

Reducing the amount of shared state will make maintaining compatibility 
easier.  A command queue introduces asynchronity and its associated 
problems, but I think it's worthwhile.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

