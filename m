From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] usbnet: Fix a race between usbnet_stop() and the BH
Date: Tue, 25 Aug 2015 19:45:06 -0700 (PDT)
Message-ID: <20150825.194506.1707236727848929581.davem@davemloft.net>
References: <55AD3A41.2040100@rosalab.ru>
	<1440447223-15945-1-git-send-email-eugene.shatokhin@rosalab.ru>
	<1440447223-15945-3-git-send-email-eugene.shatokhin@rosalab.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oneukum@suse.de, bjorn@mork.no, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: eugene.shatokhin@rosalab.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440447223-15945-3-git-send-email-eugene.shatokhin@rosalab.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Date: Mon, 24 Aug 2015 23:13:43 +0300

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

It looks like this patch needs more discussion/work.
