From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6 - bisected
Date: Fri, 27 Feb 2009 12:35:43 -0800
Message-ID: <30478.1235766943@death.nxdomain.ibm.com>
References: <491FEAD5.4090205@krogh.cc> <49A7B17F.2020408@krogh.cc> <16084.1235752119@death.nxdomain.ibm.com> <49A84802.7030502@krogh.cc>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@redhat.com>, aowi@novozymes.com
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:51327 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760184AbZB0Ufo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 15:35:44 -0500
In-reply-to: <49A84802.7030502@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh <jesper@krogh.cc> wrote:

>Jay Vosburgh wrote:
>> Jesper Krogh <jesper@krogh.cc> wrote:
>> [...]
>>> The offending commit seems to be:
>>>
>>> A test with a fresh 2.6.29-rc6 revealed that the problem has been fixed
>>> subsequently.. but still exists in 2.6.27-newest.  (havent tested
>>> 2.6.28-newest yet).
>>>
>>> Any ideas of what the "fixing" commit is .. or should that also be
>>> bisected?
>>
>> 	I went back and looked at your earlier mail.  Since you're using
>> 802.3ad mode, my first guess would be this commit:
>>
>> commit fd989c83325cb34795bc4d4aa6b13c06f90eac99
>> Author: Jay Vosburgh <fubar@us.ibm.com>
>> Date:   Tue Nov 4 17:51:16 2008 -0800
>>
>>     bonding: alternate agg selection policies for 802.3ad
>
>That didn't do it.. I applied it to 2.6.27.19 but it didnt make that work.
>dmesg | grep bond (2.6.27.19 + above patch).

	That was the only real functional change to 802.3ad, there are a
lot of other commits, but they're all style or cleanup sorts of things.

>[   13.643301] bonding: MII link monitoring set to 100 ms
>[   13.730455] bonding: bond0: enslaving eth0 as a backup interface with
>an up link.
>[   13.781934] bonding: bond0: enslaving eth1 as a backup interface with
>an up link.
>[   13.904665] bonding: bond0: enslaving eth2 as a backup interface with a
>down link.
>[   16.945264] bonding: bond0: link status definitely up for interface eth2.
>[   75.040290] bond0: no IPv6 routers present
>
>dmesg | grep bond (2.6.29-rc6)
>
>$ ssh quad02 dmesg | grep bond
>[   27.437877] bonding: MII link monitoring set to 100 ms
>[   27.445246] ADDRCONF(NETDEV_UP): bond0: link is not ready
>[   27.493260] bonding: bond0: enslaving eth0 as a backup interface with a
>down link.
>[   27.521397] bonding: bond0: enslaving eth1 as a backup interface with a
>down link.
>[   27.542332] bonding: bond0: Warning: No 802.3ad response from the link
>partner for any adapters in the bond
>[   27.611509] bonding: bond0: enslaving eth2 as a backup interface with a
>down link.
>[   27.617017] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
>[   27.642330] bonding: bond0: Warning: No 802.3ad response from the link
>partner for any adapters in the bond
>[   30.042501] bonding: bond0: link status definitely up for interface eth1.
>[   30.142505] bonding: bond0: link status definitely up for interface eth0.
>[   30.742547] bonding: bond0: link status definitely up for interface eth2.
>[   37.875044] bond0: no IPv6 routers present
>
>I just tested 2.6.28.7.. it still broken. So the fix probably has to be
>somewhere in the post 2.6.28 sets.

	It looks like the above two tests are on different machines, or
were at least done with different network cards.  Is that the case?

	I'm just wondering if what you're seeing is somehow tied to the
network devices' respective autonegotiation speeds, or some difference
in the device drivers.  The first dmesg looks to have one slow (3 sec)
and two fast ones; the second dmesg looks to have all slow devices.

	Have you tried the kernels the other way around (the first
kernel on the second machine, and vice versa)?

	I'll compile 2.6.28.7 here and see if it works for me.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
