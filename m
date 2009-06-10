From: Patrick McHardy <kaber@trash.net>
Subject: Re: SOCK_RAW does not receive broadcast (with VLAN unless PROMISC)
Date: Wed, 10 Jun 2009 17:00:10 +0200
Message-ID: <4A2FCA7A.60707@trash.net>
References: <91ac27070906081105x30171bedra10d244d382a6934@mail.gmail.com>	 <4A2E4A32.1060705@trash.net>	 <91ac27070906090608me50af3bv23b150d8d0cd0080@mail.gmail.com>	 <200906091430.32294.bcook@bpointsys.com>	 <91ac27070906100724v25c2328x6b343315358c8e12@mail.gmail.com>	 <4A2FC40E.4040106@trash.net> <91ac27070906100748p1b2cb6bax56ecc230e556ae96@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brent Cook <bcook@bpointsys.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gil Beniamini <gil.beniamini@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60470 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813AbZFJPAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 11:00:10 -0400
In-Reply-To: <91ac27070906100748p1b2cb6bax56ecc230e556ae96@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gil Beniamini wrote:
> Dear Patrick,
> Below is my try to add vlan-id 24 on eth1, followed by "ip -d link list":
> root@StudentsHPA:/home/hpa# vconfig add eth1 24
> ERROR: trying to add VLAN #24 to IF -:eth1:-  error: File exists
> 
> 5: vlan24@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
> noqueue state UP

You're apparently using the "VLAN_NAME_TYPE_PLUS_VID_NO_PAD" naming
policy, which causes name clashes when you create two VLANs with the
same ID.

I'd suggest to use iproute to create the devices, which allows you to
specify the desired name manually. Alternatively you can use vconfig
and a different naming policy.
