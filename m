From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] driver core: add device_poll interface
Date: Thu, 29 Jan 2015 14:32:29 -0800 (PST)
Message-ID: <20150129.143229.481822772678018170.davem@davemloft.net>
References: <1422312393-61485-1-git-send-email-xander.huff@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, jeff.westfahl@ni.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jaeden.amero@ni.com,
	ben.shelton@ni.com, brad.mouring@ni.com, rich.tollerton@ni.com
To: xander.huff@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422312393-61485-1-git-send-email-xander.huff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xander Huff <xander.huff@ni.com>
Date: Mon, 26 Jan 2015 16:46:32 -0600

> From: Jeff Westfahl <jeff.westfahl@ni.com>
> 
> Add the device_poll interface to the driver core. This is a generic
> interface that any struct device can take advantage of to dynamically
> switch between using interrupts and polling. Many drivers can be easily
> modified to take advantage of this feature if desired.
> 
> This interface is most likely to be used along with the RT patch. It has
> only been used thus far on Ethernet interfaces. Even with the standard
> RT change to threaded interrupts for all devices, some RT applications
> can be sensitive to even the minimal hardware interrupt that still occurs
> with threaded interrupt handlers. The device_poll interface can be used
> to completely eliminate all hardware interrupts for a device and the
> associated jitter.
> 
> This is a standalone feature that should be submitted for review and
> possible inclusion in mainline, or maybe in the RT patch.
> 
> Signed-off-by: Jeff Westfahl <jeff.westfahl@ni.com>

There is no reason any device driver needs to explicitly add support
for a feature like this.

Implement this at the IRQ handler level, and run the IRQ handler
itself from the poll thread.

No driver changes at all.

Sorry, I'm not applying this series, drivers already have to implement
too many things explicitly these days.
