From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Sun, 13 Aug 2006 16:49:34 -0700 (PDT)
Message-ID: <20060813.164934.00081381.davem@davemloft.net>
References: <1155132440.12225.70.camel@twins>
	<20060809.165846.107940575.davem@davemloft.net>
	<44DF9817.8070509@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, tgraf@suug.ch, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751730AbWHMXtO@vger.kernel.org>
To: phillips@google.com
In-Reply-To: <44DF9817.8070509@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Phillips <phillips@google.com>
Date: Sun, 13 Aug 2006 14:22:31 -0700

> David Miller wrote:
> > The reason is that there is no refcounting performed on these devices
> > when they are attached to the skb, for performance reasons, and thus
> > the device can be downed, the module for it removed, etc. long before
> > the skb is freed up.
> 
> The virtual block device can refcount the network device on virtual
> device create and un-refcount on virtual device delete.

What if the packet is originally received on the device in question,
and then gets redirected to another device by a packet scheduler
traffic classifier action or a netfilter rule?

It is necessary to handle the case where the device changes on the
skb, and the skb gets freed up in a context and assosciation different
from when the skb was allocated (for example, different from the
device attached to the virtual block device).
