From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] Convert BUG_ON to WARN_ON in bond_options.c
Date: Wed, 21 Jun 2017 15:31:15 -0700
Message-ID: <24539.1498084275@famine>
References: <CALRmy5sYL_gJsiLzQQn-2FbWowi=Bj4DkYdcOdrOHeSs4jQ3Xg@mail.gmail.com> <20170621.173655.1945994342723484710.davem@davemloft.net> <CALRmy5tn6cgWF5LP5i7w+UTwP1UJCyQoC7Mx7=RvETBUVD-yuw@mail.gmail.com> <20170621.175651.854625612625047729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: michael.j.dilmore@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20170621.175651.854625612625047729.davem@davemloft.net>
Content-ID: <24538.1498084275.1@famine>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

>From: Michael D <michael.j.dilmore@gmail.com>
>Date: Wed, 21 Jun 2017 22:41:07 +0100
>
>> I don't think you can stop it being dereferenced... you just need to
>> prevent an attacker from exploiting the null pointer dereference
>> vulnerability right? And this is done by returning the function right
>> away?
>
>What's all of this about an "attacker"?
>
>If there is a bug, we dererence a NULL pointer, and we should
>fix that bug.
>
>The BUG_ON() helps us see where the problem is while at the
>same time stopping the kernel before the NULL deref happens.

	Looking at the code more carefully than I did earlier, the only
way the BUG_ON will hit is if the rx_handler_data is NULL for a bonding
slave when this code executes.

	This should be impossible, as there doesn't appear to be any way
to get into bond_option_active_slave_set for a slave prior to
bond_enslave registering the rx_handler for that slave, as these
operations are mutexed by RTNL.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
