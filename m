From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: Fix a race between usbnet_stop() and the BH
Date: Tue, 08 Sep 2015 13:18:08 -0700 (PDT)
Message-ID: <20150908.131808.2080207445306948902.davem@davemloft.net>
References: <1441094336.3328.1.camel@suse.com>
	<1441116333-5377-1-git-send-email-eugene.shatokhin@rosalab.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oneukum@suse.de, bjorn@mork.no, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: eugene.shatokhin@rosalab.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441116333-5377-1-git-send-email-eugene.shatokhin@rosalab.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Date: Tue,  1 Sep 2015 17:05:33 +0300

> The race may happen when a device (e.g. YOTA 4G LTE Modem) is
> unplugged while the system is downloading a large file from the Net.
> 
> Hardware breakpoints and Kprobes with delays were used to confirm that
> the race does actually happen.
> 
> The race is on skb_queue ('next' pointer) between usbnet_stop()
> and rx_complete(), which, in turn, calls usbnet_bh().
> 
> Here is a part of the call stack with the code where the changes to the
> queue happen. The line numbers are for the kernel 4.1.0:
 ...
> As a result, it is possible, for example, that the skb is removed from
> dev->rxq by __skb_unlink() before the check
> "!skb_queue_empty(&dev->rxq)" in usbnet_terminate_urbs() is made. It is
> also possible in this case that the skb is added to dev->done queue
> after "!skb_queue_empty(&dev->done)" is checked. So
> usbnet_terminate_urbs() may stop waiting and return while dev->done
> queue still has an item.
> 
> Locking in defer_bh() and usbnet_terminate_urbs() was revisited to avoid
> this race.
> 
> Signed-off-by: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>

Applied, thanks.
