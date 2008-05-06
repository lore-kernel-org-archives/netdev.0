From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 1/2][ATM]: Do not free already unregistered net device.
Date: Tue, 06 May 2008 10:34:38 +0400
Message-ID: <481FFBFE.4020900@openvz.org>
References: <1210005880.5716.4.camel@Linux.home> <20080505.123703.257416714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: pcnet32@verizon.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:57287 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751987AbYEFGhe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 02:37:34 -0400
In-Reply-To: <20080505.123703.257416714.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Don Fry <pcnet32@verizon.net>
> Date: Mon, 05 May 2008 09:44:40 -0700
> 
>> I do not understand why this change was accepted.  All of the network
>> drivers I just looked at in 2.6.25 do unregister_netdev() followed
>> sometime soon by free_netdev().  Is there something different about ATM
>> devices?  I did not look at all the drivers.
> 
> Indeed, this change does look bogus.
> 
> Pavel, please take a look, unregister_netdev() indeed does not free
> the netdevice, and something (usually the caller) needs to do it.

Indeed :( My bad, I've overlooked the fact, that this device doesn't
have a ->destructor callback set (which most of the others set to the
free_netdev), so the free_netdev is to be called manually.

> I think I should revert your change.

Agree. Sorry, for the confusion.
