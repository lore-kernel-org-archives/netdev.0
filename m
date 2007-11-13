From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch 1/1][NETNS][IPV6] protect addrconf from loopback registration
Date: Tue, 13 Nov 2007 06:11:37 -0700
Message-ID: <m1ir462sty.fsf@ebiederm.dsl.xmission.com>
References: <m1ejev4dap.fsf@ebiederm.dsl.xmission.com>
	<473886E2.3020703@fr.ibm.com>
	<m16407450i.fsf@ebiederm.dsl.xmission.com>
	<20071113.105229.57026325.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=euc-jp
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dlezcano@fr.ibm.com, den@sw.ru, davem@davemloft.net,
	netdev@vger.kernel.org, xemul@openvz.org,
	containers@lists.osdl.org, benjamin.thery@bull.net
To: YOSHIFUJI Hideaki / =?euc-jp?B?tcjGo7HRzMA=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:58450 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753598AbXKMNO1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 08:14:27 -0500
In-Reply-To: <20071113.105229.57026325.yoshfuji@linux-ipv6.org> (YOSHIFUJI
	Hideaki's message of "Tue, 13 Nov 2007 10:52:29 +0900 (JST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =B5=C8=C6=A3=B1=D1=CC=C0 <yoshfuji@linux-ipv6.org> =
writes:

> In article <m16407450i.fsf@ebiederm.dsl.xmission.com> (at Mon, 12 Nov=
 2007
> 12:50:53 -0700), ebiederm@xmission.com (Eric W. Biederman) says:
>
>> My opinion is that both your analysis is slightly off (as to the cau=
se
>> of your problems) and that your approach to fix your problem is wron=
g
>> because you don't untangle the knot you keep it.
> :
>> I have register_pernet_subsys and register_per_net_device to ensure
>> that when we create a new network namespace all of the subsystems ar=
e
>> initialized before the network devices are initialize.  So ipv6 shou=
ld
>> be ready before we initialize the new loopback device comes into
>> existence.
>
> User may not load ipv6.ko at boot, and then do "modprobe ipv6".
> Do you take this into account?

Absolutely.

In the general case the infrastructure has to work for netfilter, ipv6,
and other parts of the networking stack that can be made modular.

The only limitation is that if you update struct net to add a new field
to help a modular ipv6 the core kernel needs to be recompiled.

When you load ipv6.ko late in the game first we call the init methods
which will eventually register the per network namespace registration
methods.  Then register_netdevice_notifier is called.  At which point
ipv6 is ready for the registration method.

=46or additional network namespace (which is the case that was claimed
was in trouble) the pernet_susbsys logic initializes all of the
subsystems before it initializes any of the network devices.
Effectively persevering the initialization order that exists today
with just the init methods and register_netdevice_notifier.


Eric
