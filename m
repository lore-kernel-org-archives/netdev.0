From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Wed, 08 Aug 2012 01:36:16 -0700
Message-ID: <87hasd7pbz.fsf@xmission.com>
References: <501C3527.6060809@mellanox.com>
	<20120803.143315.151094375569109262.davem@davemloft.net>
	<501C5328.4060301@mellanox.com>
	<20120803.163627.1867181085116225405.davem@davemloft.net>
	<50205DE0.7080706@mellanox.com> <87obmnfs4p.fsf@xmission.com>
	<871ujjfkb1.fsf@xmission.com>
	<CAJZOPZ+W0wfa38LejXt0gvBNa8Q6pWVZOs7xctHGRQXHAeMYPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ali Ayoub <ali@mellanox.com>, David Miller <davem@davemloft.net>,
	ogerlitz@mellanox.com, roland@kernel.org, netdev@vger.kernel.org,
	sean.hefty@intel.com, erezsh@mellanox.co.il, dledford@redhat.com
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:46767 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470Ab2HHIpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 04:45:33 -0400
In-Reply-To: <CAJZOPZ+W0wfa38LejXt0gvBNa8Q6pWVZOs7xctHGRQXHAeMYPQ@mail.gmail.com>
	(Or Gerlitz's message of "Wed, 8 Aug 2012 09:04:55 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <or.gerlitz@gmail.com> writes:

> Eric W. Biederman <ebiederm@xmission.com> wrote:
>>> Ali Ayoub <ali@mellanox.com> writes:
>
>>> Among other things, the main benefit we're targeting is to allow IPoE
>>> traffic within the VM to go through the (Ethernet) vBridge down to the
>>> eIPoIB PIF, and eventually to IPoIB and to the IB network.
>
>> Oh yes.  It just occurred to me there is huge problem with eIPoIB as
>> currently presented in these patches.  It breaks DHCPv4 the same way
>> it breaks ARP, but DHCPv4 is not fixed up.
>
> To put things in place, DHCPv4 is supported with eIPoIB, the DHCP
> UDP/IP payload  isn't touched, only need to set the BOOTP broadcast
> flag in the dhcp server config file.

Wrong.  DHCPv4 is broken over eIPoIB. 

Coming from ethernet
htype == 1 not 32 as required by RFC4390
hlen == 6 not 0 as required by RFC4390
The chaddr field is has 6 bytes of the ethernet mac address not the
required 16 bytes of 0.

The client-identifier field is optional over ethernet.

An ethernet DHCPv4 client simply does not generate a dhcp packet that
conforms to RFC4390.

Therefore DHCPv4 over eIPoIB is broken, and a dhcp server or relay
may reasonably look at the DHCP packet and drop it because it is
garbage.

You might find a forgiving dhcp server that doesn't drop insane packets
on the floor and tries to make things work.

I am sorry.  eIPoIB is broken as designed.  eIPoIB most assuredly is not
compatible with ethernet.  eIPoIB most definitely does not work even for
the general case of transporing IP traffic.  Claiming that eIPoIB is any
else is a lie.

Eric
