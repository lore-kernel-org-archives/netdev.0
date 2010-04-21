From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Wed, 21 Apr 2010 09:28:07 -0700
Message-ID: <C7F475A7.2A1D9%scofeldm@cisco.com>
References: <201004211517.58062.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@redhat.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:36295 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755804Ab0DUQ2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 12:28:12 -0400
In-Reply-To: <201004211517.58062.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/21/10 6:17 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:

> On Tuesday 20 April 2010, Scott Feldman wrote:
>> On 4/20/10 9:19 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:
>> 
>>>> In the case of devices that can do adjacent switch negotiations directly.
>>> 
>>> I thought the idea to deal with those devices was to beat sense into
>>> the respective developers until they do the negotiation in software 8-)
>> 
>> When the device can do the negotiation directly with the switch, why does it
>> make sense to bypass that and use software on the host?  I don't think we'd
>> want to give up on link speed/duplex auto-negotiation and punt those setting
>> back to the user/host like in the old days.
> 
> For the link negotiation, the card is the right place because it's necessary
> to get the link working before the OS can talk to the switch.
> For VDP, that's different because the hypervisor needs to talk to the switch
> before the guest can communicate, so there is no interdependency.
> 
> More importantly, the card cannot possibly do the protocol by itself,
> because the information that gets exchanged is specific to the hypervisor and
> the guest, not to the hardware. What you have implemented is another protocol
> between the hypervisor and the NIC that exchanges the exact same data that
> then gets sent to the switch. We already need to have an implementation that
> sends this data to the switch from user space for all cards that don't do
> it in firmware, so doing an alternative path in the adapter really creates
> more work for the users, and means that when we fix bugs or add features
> to the common code, you don't get them ;-).

But the point of iovnl was to provide a single mechanism for both types of
adapters (w/ or w/o firmware assist) to exchange this data with the switch,
therefore making the difference in the adapters transparent to the user.  So
I'm missing your point about more work for the users.

-scott

