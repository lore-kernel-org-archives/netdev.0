From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Wed, 18 Feb 2009 07:55:45 +0100
Message-ID: <499BB0F1.50507@linux.vnet.ibm.com>
References: <alpine.LFD.2.00.0902131413120.3179@localhost.localdomain> <20090217095232.5da06b9f@werewolf.home> <200902172001.41804.arvidjaar@mail.ru> <20090217.142946.232071526.davem@davemloft.net> <25143.1234932076@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, arvidjaar@mail.ru, rjw@sisk.pl,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	jamagallon@ono.com, linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:49258 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbZBRGzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 01:55:47 -0500
In-Reply-To: <25143.1234932076@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have the same issue with the qeth_l3 driver (it requires IPv6 symbols).
Distributors compile with IPv6 but some customes want to disable IPv6 without
building a custom kernel. If there would be a generic solution to address
this kind of runtime IPv6 dependencies this would be creat.  

Valdis.Kletnieks@vt.edu schrieb:
> On Tue, 17 Feb 2009 14:29:46 PST, David Miller said:
>> Don't configure ipv6 into your kernel, really.
>>
>> There is no other way to handle this.  If we want to support
>> IPV6 layer things in the bonding driver, it is going to
>> call helper functions in the ipv6 module and therefore must
>> be able to load it and use functions in it.
> 
> What does a poor corporate user do if they're running a distro kernel that
> was built with CONFIG_IPV6, but local security policy says "Disable IPv6
> because we don't do it yet, or because it breaks mission-critical software
> package XYZ?"  There's a *lot* of people who implement that by the "block
> the ipv6 module from loading" trick.  And building a kernel that doesn't
> include IPv6 may not be feasible due to vendor certification issues...
> 
> Heck, *I*'m almost in that boat - probably need to use bonded ethernet on some
> servers because we can't get 10GigE, but the software used in the project the
> servers were bought for blows chunks if it gets a whiff of an IPv6 address.
> Ended up spending 3 weeks doing a massive kludgery of one sort in DNS for the
> rest of the world, and equally massive lying in /etc/hosts for the hosts...
> (Don't ask - it was long and ugly, and just disabling the module would have
> saved me about 2.95 weeks of work, so I know where those people are coming
> from...)
> 


