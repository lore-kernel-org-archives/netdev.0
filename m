From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically
 configured
Date: Thu, 19 Feb 2015 15:40:41 -0500 (EST)
Message-ID: <20150219.154041.184372158520813993.davem@davemloft.net>
References: <20150213212830.GA29912@electric-eye.fr.zoreil.com>
	<54E1568D.5000100@windriver.com>
	<20150216120345.4dfd9950@uryu.home.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yanjun.Zhu@windriver.com, romieu@fr.zoreil.com,
	netdev@vger.kernel.org, mst@redhat.com, jasowang@redhat.com,
	viro@zeniv.linux.org.uk, sergei.shtylyov@cogentembedded.com,
	jonathon.reinhart@gmail.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692AbbBSUko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 15:40:44 -0500
In-Reply-To: <20150216120345.4dfd9950@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 16 Feb 2015 12:03:45 -0500

> I would like to propose this is as a more complete alternative.
> 
> From: Stephen Hemminger <stephen@networkpluber.org>
> Subject: [PATCH] tun: support overriding ethtool information
> 
> Extensions to allow masqurade of ethtool info and device statistics.
> This is useful to provide correct information to SNMP and OSPF routing
> daemons when doing hw/sw offload of network device.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

We need a consistent policy regarding link attributes of encapsulating
"software" devices.

I see three realistic options:

1) Create a link state indication which means "I am a software device,
   so I don't really have a link state in the traditional sense"

2) Don't implement the link set/get operations at all on software
   devices.

   People can use ETHTOOL_GLINK to see if the thing is "up"

3) Propagate the ultimate physical transport parameters into what
   the software device advertises.

It's important to carefully pick one of these, and consistently apply
it to all of our software devices.

I don't want TUN doing one thing, ipv4 tunnels doing another, etc.
