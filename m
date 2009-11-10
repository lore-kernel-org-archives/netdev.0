From: Ed Cashin <ecashin@coraid.com>
Subject: Re: [PATCH 04/10] AOE: use rcu to find network device
Date: Tue, 10 Nov 2009 15:01:49 -0500
Message-ID: <8ffe0a1df67d13a45a413f40d00dd80a@coraid.com>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.409162953@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: shemminger@vyatta.com, davem@davemloft.net, ecashin@coraid.com,
	harvey.harrison@gmail.com, bzolnier@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.co-raid.com ([12.51.113.4]:39500 "EHLO coraid.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758023AbZKJUSN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 15:18:13 -0500
In-Reply-To: <20091110175647.409162953@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue Nov 10 13:07:37 EST 2009, shemminger@vyatta.com wrote:
> This gets rid of another use of read_lock(&dev_base_lock) by using
> RCU. Also, it only increments the reference count of the device actually
> used rather than holding and releasing every device
> 
> Compile tested only.

This function runs once a minute when the aoe driver is loaded,
if you'd like to test it a bit more.

It looks like there's no dev_put corresponding to the dev_hold
after the changes.

-- 
  Ed
