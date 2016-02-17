From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] phy: marvell: Fix and unify reg-init behavior
Date: Wed, 17 Feb 2016 16:21:16 -0500 (EST)
Message-ID: <20160217.162116.1569654379533423352.davem@davemloft.net>
References: <1455576405-16263-1-git-send-email-clemens.gruber@pqgruber.com>
	<20160216152902.GA29482@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clemens.gruber@pqgruber.com, netdev@vger.kernel.org,
	f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
	festevam@gmail.com
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160216152902.GA29482@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 16 Feb 2016 16:29:02 +0100

> On Mon, Feb 15, 2016 at 11:46:45PM +0100, Clemens Gruber wrote:
>> For the Marvell 88E1510, marvell_of_reg_init was called too late, in the
>> config_aneg function.
>> Since commit 113c74d83eef ("net: phy: turn carrier off on phy attach"),
>> this lead to the link not coming up at boot anymore, due to the phy
>> state machine being stuck at waiting for interrupts (off by default on
>> the 88E1510).
>> For seven other Marvell PHYs, marvell_of_reg_init was not called at all.
>> 
>> Add a generic marvell_config_init function, which in turn calls
>> marvell_of_reg_init.
>> PHYs, which already have a specific config_init function with a call to
>> marvell_of_reg_init, are left untouched. The generic marvell_config_init
>> function is called for all the others, to get consistent behavior across
>> all Marvell PHYs.
>> 
>> Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>
> 
> Hi Clemens
> 
> Thanks for extending your original patch to make things more
> consistent.
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> fixes: 113c74d83eef ("net: phy: turn carrier off on phy attach")

Applied, thanks.

BTW, "Fixes: " should be capitalized.
