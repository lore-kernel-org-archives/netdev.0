From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: stmmac: allow changing the MTU while the
 interface is running
Date: Wed, 05 Apr 2017 07:49:32 -0700 (PDT)
Message-ID: <20170405.074932.195620842509788140.davem@davemloft.net>
References: <20170404121854.606-1-niklass@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        Joao.Pinto@synopsys.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        niklass@axis.com
To: niklas.cassel@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170404121854.606-1-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Tue, 4 Apr 2017 14:18:54 +0200

> From: Niklas Cassel <niklas.cassel@axis.com>
> 
> Setting ethtool ops for stmmac is only allowed when the interface is up.
> Setting MTU (a netdev op) for stmmac is only allowed when the interface
> is down.
> 
> It seems that the only reason why MTU cannot be changed when running is
> that we have not bothered to implement a nice way to dealloc/alloc the
> descriptor rings.
> 
> To make it less confusing for the user, call ndo_stop() and ndo_open()
> from ndo_change_mtu(). This is not a nice way to dealloc/alloc the
> descriptor rings, since it will announce that the interface is being
> brought down/up to user space, but there are several other drivers doing
> it this way, and it is arguably better than just returning -EBUSY.
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>

You can't do this with no error handling.

Instead, you must do this using a "prepare", "commit" sequence.
First making sure you can reallocate all necessary resources,
and make the config change, before actually doing so.

You're not even checking if the re-open fails, meaning that an MTU
change can cause the interface to shut down.  That is simply not
acceptable.
