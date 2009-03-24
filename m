From: Patrick McHardy <kaber@trash.net>
Subject: Re: Network Device Naming mechanism and policy
Date: Tue, 24 Mar 2009 18:04:14 +0100
Message-ID: <49C9128E.6040202@trash.net>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com>	 <49C9087C.5070907@trash.net> <1237912858.9082.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Domsch <Matt_Domsch@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38895 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762359AbZCXREX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 13:04:23 -0400
In-Reply-To: <1237912858.9082.39.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams wrote:
> On Tue, 2009-03-24 at 17:21 +0100, Patrick McHardy wrote:
>> I would classify this as a bug, especially the fact that udev doesn't
>> undo a failed rename, so you end up with ethX_rename. Virtual devices
>> using the same MAC address trigger this reliably unless you add
>> exceptions to the udev rules.
> 
> Any particular reason the MAC addresses are the same?  This came up a
> while ago with the 'dnet' device in the thread "Dave DNET ethernet
> controller".
> 
> If the MAC address isn't a UUID for the device, then *what* is?

Sometimes (I was referring to virtual devices) there may not be
one, thats correct.

> If there isn't one, then certainly udev can't be blamed for getting
> ordering or names wrong, because there's nothing to use to actually
> match up the device to a name, uniquely. 

I agree that udev can't do anything useful in that case. I would
prefer it it wouldn't even try though instead of messing with the
names and leaving a bunch of _rename devices around. Sure, I can
add a rule to disable it, but that shouldn't be necessary.

Generally, I'm wondering whether it should touch virtual network
devices at all since the MAC addresses are often not persistent,
sometimes not unique and the name might have already been chosen
explicitly by the administrator when creating the device.

Currently there are some rules to ignore a couple of known virtual
devices types. Are there actually cases where renaming virtual
devices is desired? Otherwise a more future-proof way than
blacklisting each type individually would be to add some attribute
informing udev that the device has no unique key and should be
ignored.

