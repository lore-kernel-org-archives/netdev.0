From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: emac: emac gigabit ethernet controller driver
Date: Tue, 15 Dec 2015 16:41:18 +0100
Message-ID: <1579270.z2ZaCA4LQo@wuerfel>
References: <1450138740-32562-1-git-send-email-gavidov@codeaurora.org> <1594472.ixZvj6PYdz@wuerfel> <56702EEC.8000506@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Christopher Covington <cov@codeaurora.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Gilad Avidov <gavidov@codeaurora.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, gregkh@linuxfoundation.org,
	vikrams@codeaurora.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56702EEC.8000506@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 15 December 2015 09:17:00 Timur Tabi wrote:
> Arnd Bergmann wrote:
> > We generally want to use readl/writel rather than the relaxed versions,
> > unless it is in performance-critical code.
> 
> What about if we have 20+ writes in a row, for example, when 
> initializing a part?  I've seen code like this:
> 
>         writel_relaxed(...);
>         writel_relaxed(...);
>         writel_relaxed(...);
>         ...
>         writel(...); // HW now inited, so enable

If that's in the probe() called from it function, just use writel() everywhere,
a few extra microseconds won't kill the boot time. In general, if a user would
notice the difference, use the relaxed version and add a comment to explain
how you proved it's correct, otherwise stay with the default accessors.

	Arnd
