From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [NET] [ISDN]: Do not validate ISDN net device address
 prior to interface-up
Date: Sun, 13 Apr 2008 08:29:51 +0200
Message-ID: <4801A85F.8090906@trash.net>
References: <1207839617.4311.6.camel@compaq.thuisdomein>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040804060507040308070804"
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	Jeff Garzik <jgarzik@redhat.com>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34483 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbYDMG34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 02:29:56 -0400
In-Reply-To: <1207839617.4311.6.camel@compaq.thuisdomein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040804060507040308070804
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Paul Bolle wrote:
> From: Paul Bolle <pebolle@tiscali.nl>
>    
> Commit bada339 (Validate device addr prior to interface-up) caused a regression
> in the ISDN network code, see: http://bugzilla.kernel.org/show_bug.cgi?id=9923
> The trivial fix is to remove the pointer to eth_validate_addr() in the
> net_device struct in isdn_net_init().
>     
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
> Please note that I hardly know what the device address validation is good for.
> Neither do I know much about the ISDN network code or why the device address
> validation fails for ISDN interfaces. This patch however basically reverts 
> commit bada339 just for the ISDN network code. I can't think of any side
> effects.

The patch looks fine. is_valid_ether_addr() fails because the ISDN
device's address is 00:00:00:00:00:00 at this point.

> http://bugzilla.kernel.org/show_bug.cgi?id=9923 would have been much easier to
> track down if eth_validate_addr() would somehow complain aloud if an address 
> is invalid. Shouldn't it make at least some noise?

I guess it should return -EADDRNOTAVAIL similar to eth_mac_addr()
when validation fails.

Signed-off-by: Patrick McHardy <kaber@trash.net>


--------------040804060507040308070804
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index a7b4175..a80839b 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -301,7 +301,7 @@ static int eth_change_mtu(struct net_device *dev, int new_mtu)
 static int eth_validate_addr(struct net_device *dev)
 {
 	if (!is_valid_ether_addr(dev->dev_addr))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	return 0;
 }

--------------040804060507040308070804--
