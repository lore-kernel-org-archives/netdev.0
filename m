From: Patrick McHardy <kaber@trash.net>
Subject: Re: SOCK_RAW does not receive broadcast (with VLAN unless PROMISC)
Date: Wed, 10 Jun 2009 16:32:46 +0200
Message-ID: <4A2FC40E.4040106@trash.net>
References: <91ac27070906081105x30171bedra10d244d382a6934@mail.gmail.com>	 <4A2E4A32.1060705@trash.net>	 <91ac27070906090608me50af3bv23b150d8d0cd0080@mail.gmail.com>	 <200906091430.32294.bcook@bpointsys.com> <91ac27070906100724v25c2328x6b343315358c8e12@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brent Cook <bcook@bpointsys.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gil Beniamini <gil.beniamini@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59884 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759487AbZFJOcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 10:32:51 -0400
In-Reply-To: <91ac27070906100724v25c2328x6b343315358c8e12@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Again, please don't top post.

Gil Beniamini wrote:
> My application is a "proxy" and need to support few VLANs (for example vlan 24).
> I define all vlans on interface 'eth0' which is my "out i/f", while
> the other interface 'eth1' (used as "in i/f") I use with PF_PACKET /
> SOCK_RAW in order to handle VLANs by my application (starting with
> "arp broadcast").
> When I try to define the same (relevant VLAN) on eth1 (inorder to
> check your suggestion), I get "Error: trying to add VLAN #24 to IF
> -:eth1:- error: file exist".
> It seems that linux does not allow to define the same VLAN # on more
> than a single i/f?!

No, that has got to be a mistake. You can use the same ID once
per underlying device:

# ip -d link list

4: vlan0@dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN
     link/ether d6:1f:c0:bd:b2:ec brd ff:ff:ff:ff:ff:ff
     vlan id 1000 <REORDER_HDR>
6: vlan1@dummy1: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN
     link/ether 8a:17:13:5d:87:1a brd ff:ff:ff:ff:ff:ff
     vlan id 1000 <REORDER_HDR>

If it doesn't work for you, please post the full commands
and ip -d link list output you used.
