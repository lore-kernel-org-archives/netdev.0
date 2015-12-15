From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: emac: emac gigabit ethernet controller driver
Date: Tue, 15 Dec 2015 22:55:27 +0100
Message-ID: <2492153.N3Ga92jYtq@wuerfel>
References: <1450138740-32562-1-git-send-email-gavidov@codeaurora.org> <1579270.z2ZaCA4LQo@wuerfel> <56708183.4090005@codeaurora.org>
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
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <56708183.4090005@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 15 December 2015 15:09:23 Timur Tabi wrote:
> Arnd Bergmann wrote:
> > If that's in the probe() called from it function, just use writel() everywhere,
> > a few extra microseconds won't kill the boot time. In general, if a user would
> > notice the difference, use the relaxed version and add a comment to explain
> > how you proved it's correct, otherwise stay with the default accessors.
> 
> What about adding a wmb() after the last writel()?  This driver does 
> that a lot.  Is that something we want to discourage?  I can understand 
> how we would want to make sure that the last write is posted before the 
> function exits.

Please explain in a comment specifically which race you are closing by
ensuring that the write gets posted. What does it race against?

As I said earlier, guaranteeing that a write gets posted does not mean
it has arrived at the device, we only get that behavior after a subsequent
read from the same device, but you don't need a wmb() between the
write and the read to guarantee this.

If you have an odd bus that does not follow those rules, it may in fact be
best to have a separate set of I/O accessors and not use readl/writel at all.

	Arnd
