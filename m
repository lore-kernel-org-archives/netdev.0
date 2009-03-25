From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] IPv6: Add 'autoconf' and 'disable_ipv6' module parameters
Date: Wed, 25 Mar 2009 11:28:06 -0400
Message-ID: <49CA4D86.4070403@hp.com>
References: <> <1237945752-14362-1-git-send-email-brian.haley@hp.com> <49C99315.6070504@hp.com> <alpine.LNX.2.00.0903250526050.6682@firda.kolla.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Kolbj=F8rn_Barmen?= <linux@kolla.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:32059 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762909AbZCYP2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 11:28:10 -0400
In-Reply-To: <alpine.LNX.2.00.0903250526050.6682@firda.kolla.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kolbj=F8rn Barmen wrote:
> On Tue, 24 Mar 2009, Vlad Yasevich wrote:
>=20
>> Brian Haley wrote:
>>> This is the quick and easy patch to add autoconf and
>>> disable_ipv6 module parameters to IPv6.  I don't think anything
>>> more complicated is needed, assuming you play with the /etc
>>> configuration files.
>>>
>>> For example, if you wanted to enable IPv6 just on 'lo' you
>>> would:
>>>
>>> 1. Add "ipv6" to /etc/modules (if you don't, step #3 might fail)
>>>
>>> 2. Add this to /etc/modprobe.conf:
>>>
>>> 	options ipv6 disable_ipv6=3D1
>>>
>>> 3. Add these to /etc/sysctl.conf:
>>>
>>> 	net.ipv6.conf.all.disable_ipv6=3D0
>>> 	net.ipv6.conf.lo.disable_ipv6=3D0
>> This is kind of confusing.  First you say, disable IPv6, then you sa=
y enable IPv6, but
>> nothing happens.  Unless you typo-ed the 'all.disable_ipv6 =3D 0'...
>=20
> I bet that should have been "net.ipv6.conf.all.disable_ipv6=3D1" yes.=
 :)

No, the module parameter disabled it, but we need to re-enable the=20
=2Eall.disable_ipv6 knob in order for lo to be able to configure itself=
=2E=20
If I follow Vlad's advice of only setting the .default knob then you=20
won't have to do this.

>> Also, it looks like if someone decides to switch IPv6 back on for a =
particular
>> interface, they would have to wait until the next RA to get an addre=
ss.  Not an
>> optimum solution.
>=20
> Isnt this the normal way anyways, or do new interfaces send some sort=
 of
> "I'm new here, give me a prefix and router announcement, please!" nor=
mally
> when they go online? If so, maybe that should be done here as well.

I'll see about putting in a callback to send a router solicitation.  Bu=
t=20
on the flip side if someone changes eth0.disable_ipv6=3D0 to 1, we won'=
t=20
be removing the address either.  An ifdown/ifup cycle would remove the=20
need for us to do anything here.

-Brian
