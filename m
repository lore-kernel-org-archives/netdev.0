From: David Miller <davem@davemloft.net>
Subject: Re: Avoid deadlock situation due to use of xmit_lock
Date: Tue, 06 Dec 2016 10:06:07 -0500 (EST)
Message-ID: <20161206.100607.919832811727709338.davem@davemloft.net>
References: <1480719966-12839-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480719966-12839-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Sat,  3 Dec 2016 00:06:04 +0100

> after stumbling over a potential deadlock situation in the altera driver 
> (see http://marc.info/?l=linux-netdev&m=148054615230447&w=2), I checked
> all other ethernet drivers for the same issue and actually found it in 2
> more, namely stmmac, and sxgbe. Please see the commit messages for a 
> description of the problem.
> These 2 patches fix the concerning drivers.

First of all, I don't want to apply these patches without proper testing
and ACKs from the individual driver maintainers.

For both of these drivers, this situation only exists because the TX
path uses the unnecessary ->tx_lock.  This private lock should be
removed completely and the driver should use the lock the mid-layer
already holds in the transmit path and take it in the TX reclaim path
instead of the private ->tx_lock.
