From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: use mutex for hw settings
Date: Wed, 08 Oct 2014 15:45:13 -0400 (EDT)
Message-ID: <20141008.154513.1944594723904521723.davem@davemloft.net>
References: <1394712342-15778-58-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-58-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 7 Oct 2014 13:36:30 +0800

> Use mutex to avoid that the serial hw settings would be interrupted
> by other settings. Although there is no problem now, it makes the
> driver more safe.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

I think a much simpler fix is to take rtnl_lock() in the workqueue
function and suspend/resume ops.

Every other place you are adding the mutex already holds the RTNL
mutex.
