From: Patrick McHardy <kaber@trash.net>
Subject: Re: Handling set_mac_address in set_rx_mode
Date: Mon, 02 Jul 2007 14:20:16 +0200
Message-ID: <4688ED80.4090105@trash.net>
References: <4686A614.1000709@trash.net> <4686BF35.8080605@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48653 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbXGBMUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 08:20:32 -0400
In-Reply-To: <4686BF35.8080605@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Patrick McHardy wrote:
> 
>> While adding support for secondary unicast addresses to 8021q and
>> macvlan, I've tried keeping dev->dev_addr as global address on
>> dev->uc_list and have drivers skip them to avoid having all
>> dev_unicast_add users implement a state machine like this:
> 
> 
> [...]
> 
> Something that is not entirely clear to me...  This has zero impact on
> existing drivers, right?


Yes, since the set_rx_mode hook is new anyway this would only
affect drivers offering it (which is none so far). But this
idea turned not to be so good anyways, without the
set_mac_address callback the driver can't validate the new
address.

