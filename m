From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/1] tun: change speed from 10M to dynamically configured
Date: Fri, 20 Feb 2015 10:01:10 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAE6737@AcuExch.aculab.com>
References: <20150213212830.GA29912@electric-eye.fr.zoreil.com>
	<54E1568D.5000100@windriver.com>	<20150216120345.4dfd9950@uryu.home.lan>
 <20150219.154041.184372158520813993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Yanjun.Zhu@windriver.com" <Yanjun.Zhu@windriver.com>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"jonathon.reinhart@gmail.com" <jonathon.reinhart@gmail.com>
To: 'David Miller' <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:50972 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753823AbbBTKB6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 05:01:58 -0500
In-Reply-To: <20150219.154041.184372158520813993.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
...
> We need a consistent policy regarding link attributes of encapsulating
> "software" devices.
> 
> I see three realistic options:
> 
> 1) Create a link state indication which means "I am a software device,
>    so I don't really have a link state in the traditional sense"
> 
> 2) Don't implement the link set/get operations at all on software
>    devices.
> 
>    People can use ETHTOOL_GLINK to see if the thing is "up"
> 
> 3) Propagate the ultimate physical transport parameters into what
>    the software device advertises.
> 
> It's important to carefully pick one of these, and consistently apply
> it to all of our software devices.

You also need to be careful to not break existing 'stuff'.

We've connected a single USB ethernet port into a 'bond' (with
nothing else) in order to get a stable interface and IP address
that doesn't bounce on transient USB errors.

If the absence of the physical interface caused the state of bond0
to change and that got propagated through the routing tables then
we'd get TCP disconnects reported for things that would only see
recovered packet loss.

	David
