From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: Properly propagate errors from
 dsa_switch_setup_one
Date: Sun, 31 May 2015 21:50:55 -0700 (PDT)
Message-ID: <20150531.215055.1064973162484363630.davem@davemloft.net>
References: <1432920586-20482-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, linux@roeck-us.net
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45427 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764AbbFAEu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 00:50:56 -0400
In-Reply-To: <1432920586-20482-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 29 May 2015 10:29:46 -0700

> While shuffling some code around, dsa_switch_setup_one() was introduced,
> and it was modified to return either an error code using ERR_PTR() or a
> NULL pointer when running out of memory or failing to setup a switch.
> 
> This is a problem for its caler: dsa_switch_setup() which uses IS_ERR()
> and expects to find an error code, not a NULL pointer, so we still try
> to proceed with dsa_switch_setup() and operate on invalid memory
> addresses. This can be easily reproduced by having e.g: the bcm_sf2
> driver built-in, but having no such switch, such that drv->setup will
> fail.
> 
> Fix this by using PTR_ERR() consistently which is both more informative
> and avoids for the caller to use IS_ERR_OR_NULL().
> 
> Fixes: df197195a5248 ("net: dsa: split dsa_switch_setup into two functions")
> Reported-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
