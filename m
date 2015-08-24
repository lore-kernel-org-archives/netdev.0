From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: Fix two races between usbnet_stop() and the BH
Date: Mon, 24 Aug 2015 10:43:28 -0700 (PDT)
Message-ID: <20150824.104328.554582952440857559.davem@davemloft.net>
References: <55D436D5.6010105@rosalab.ru>
	<87k2sreefu.fsf@nemi.mork.no>
	<55D46F85.50608@rosalab.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, oneukum@suse.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: eugene.shatokhin@rosalab.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55D46F85.50608@rosalab.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Date: Wed, 19 Aug 2015 14:59:01 +0300

> So the following might be possible, although unlikely:
> 
> CPU0             CPU1
>                  clear_bit: read dev->flags
>                  clear_bit: clear EVENT_RX_KILL in the read value
> 
> dev->flags=0;
> 
>                  clear_bit: write updated dev->flags
> 
> As a result, dev->flags may become non-zero again.

Is this really possible?

Stores really are "atomic" in the sense that the do their update
in one indivisible operation.

Atomic operations like clear_bit also will behave that way.

If a clear_bit is in progress, the "dev->flags=0" store will not be
able to grab the cache line exclusively until the clear_bit is done.

So I think the above sequent of events is completely impossible.  Once
a clear_bit starts, a write by another foreign agent on the bus is
absolutely impossible to legally occur until the clear_bit completes.

I think this is a non-issue.
