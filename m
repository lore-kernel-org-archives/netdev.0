From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: RFC: dsa slave open handling
Date: Mon, 7 Mar 2011 19:23:08 +0100
Message-ID: <20110307182308.GY16649@mail.wantstofly.org>
References: <871v2inajz.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:51055 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006Ab1CGSXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 13:23:09 -0500
Content-Disposition: inline
In-Reply-To: <871v2inajz.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 07, 2011 at 05:46:08PM +0100, Peter Korsgaard wrote:

> Hi,

Hello,


> Currently the state of the dsa master device and slave devices are not
> synchronized which leads to various issues. With dsa, the master device
> needs to be running before you can use the slave devices, but it
> shouldn't be used directly for I/O.

I think this should not be handled any differently than VLAN interfaces,
where eth0 needs to be up before you can exchange packets over eth0.123.

IOW, if you want to do DHCP over wan (a DSA-tunneled interface over
eth0), then just use an initramfs that sets eth0 up and then runs a
DHCP client on wan.

The fact that in-kernel IP autoconfiguration can't deal with DSA just
means that you shouldn't use the in-kernel IP autoconfiguration -- you
could "fix" this with one of your proposed patches, but then the next
thing will be someone wanting to do in-kernel IP autoconfig over a VLAN
interface stacked onto a DSA interface, etc, which then still wouldn't
work.


cheers,
Lennert
