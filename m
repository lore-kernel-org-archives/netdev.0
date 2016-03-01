From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] r8169:issues fix.
Date: Tue, 01 Mar 2016 15:24:53 -0500 (EST)
Message-ID: <20160301.152453.1743613743070525198.davem@davemloft.net>
References: <1456476046-5436-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456476046-5436-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chunhao Lin <hau@realtek.com>
Date: Fri, 26 Feb 2016 16:40:43 +0800

> This series of patches fix 3 issues that are listed below.
> 
> Chunhao Lin (3):
>   r8169:fix nic sometimes doesn't work after changing the mac address.
>   r8169:eliminate error message in using ethtool -S when nic is down.
>   r8169: Enable RX_MULTI_EN for RTL_GIGA_MAC_VER_41~48

I don't agree with changes #1 and #2.

If you are going to go to a model where every single configuration
operation is recorded in software and performed at resume time, then
really do it and fix it in the whole driver.  As currently coded you
are leaving lots of known bugs in the driver.

#2 is even a worse situation.  If you are going to handle things this
way you must sync the counters when the suspend happens, so that the
statistics get call receives up to date values.
