From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Porting problem: ndo_set_multicast_list removed
Date: Mon, 24 Dec 2012 11:16:27 -0800
Message-ID: <1356376587.20133.9693.camel@edumazet-glaptop>
References: <20121224163005.GA3970@zuhnb712>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernelnewbies@kernelnewbies.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Woody Wu <narkewoody@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33830 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129Ab2LXTQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2012 14:16:31 -0500
In-Reply-To: <20121224163005.GA3970@zuhnb712>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-25 at 00:30 +0800, Woody Wu wrote:
> Hi, list
> 
> I am porting an ethernet driver from 2.6.x to 3.7.1.  I found in the new
> kernel, the ndo_set_multicast_list method in the net_device_ops had been
> removed. What's the story behind?  Can I simply ignore this method
> defined in an old driver?
> 
> Please also help to check the below code, is the list of the operations
> defined for my driver enough or not?
> 
> const struct net_device_ops ax_netdev_ops = {
> 	.ndo_open		= mydriver_open,
> 	.ndo_stop		= mydriver_close,
> 	.ndo_start_xmit		= mydriver_start_xmit,
> 	.ndo_get_stats		= mydriver_get_stats,
> 	/*.ndo_set_multicast_list = mydriver_set_multicast_list,*/
> 	.ndo_set_mac_address 	= mydriver_set_mac_address,
> };
> 
> Thanks in advance.
> 

Take a look at :

commit afc4b13df143122f99a0eb10bfefb216c2806de0
Author: Jiri Pirko <jpirko@redhat.com>
Date:   Tue Aug 16 06:29:01 2011 +0000

    net: remove use of ndo_set_multicast_list in drivers
    
    replace it by ndo_set_rx_mode
    
    Signed-off-by: Jiri Pirko <jpirko@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
