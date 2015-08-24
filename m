From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: Fix two races between usbnet_stop() and the BH
Date: Mon, 24 Aug 2015 11:35:38 -0700 (PDT)
Message-ID: <20150824.113538.2034261393606624731.davem@davemloft.net>
References: <20150824.104328.554582952440857559.davem@davemloft.net>
	<Pine.LNX.4.44L0.1508241403100.5935-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eugene.shatokhin@rosalab.ru, bjorn@mork.no, oneukum@suse.com,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: stern@rowland.harvard.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1508241403100.5935-100000@iolanthe.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Stern <stern@rowland.harvard.edu>
Date: Mon, 24 Aug 2015 14:06:15 -0400 (EDT)

> On Mon, 24 Aug 2015, David Miller wrote:
>> Atomic operations like clear_bit also will behave that way.
> 
> Are you certain about that?  I couldn't find any mention of it in
> Documentation/atomic_ops.txt.
> 
> In theory, an architecture could implement atomic bit operations using 
> a spinlock to insure atomicity.  I don't know if any architectures do 
> this, but if they do then the scenario above could arise.

Indeed, we do have platforms like 32-bit sparc and parisc that do this.

So, taking that into consideration, this is a bit unfortunate and on
such platforms we do have this problem.
