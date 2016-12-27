From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: synchronize stmmac_open and
 stmmac_dvr_probe
Date: Mon, 26 Dec 2016 23:54:36 -0500 (EST)
Message-ID: <20161226.235436.131087168899382517.davem@davemloft.net>
References: <1482839100-20612-1-git-send-email-hock.leong.kweh@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joao.Pinto@synopsys.com, peppe.cavallaro@st.com,
        seraphin.bonnaffe@st.com, alexandre.torgue@gmail.com,
        manabian@gmail.com, niklas.cassel@axis.com, johan@kernel.org,
        pavel@ucw.cz, boon.leong.ong@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, weifeng.voon@intel.com,
        lars.persson@axis.com
To: hock.leong.kweh@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482839100-20612-1-git-send-email-hock.leong.kweh@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kweh, Hock Leong"	<hock.leong.kweh@intel.com>
Date: Tue, 27 Dec 2016 19:44:59 +0800

> From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
> 
> If kernel module stmmac driver being loaded after OS booted, there is a
> race condition between stmmac_open() and stmmac_mdio_register(), which is
> invoked inside stmmac_dvr_probe(), and the error is showed in dmesg log as
> PHY not found and stmmac_open() failed:
 ...
> The resolution used wait_for_completion_interruptible() to synchronize
> stmmac_open() and stmmac_dvr_probe() to prevent the race condition
> happening.
> 
> Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>

The proper thing to do is to make sure register_netdevice() is not
invoked until it is %100 safe to call stmmac_open().
