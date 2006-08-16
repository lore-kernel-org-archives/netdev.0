From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Wed, 16 Aug 2006 13:00:31 +0400
Message-ID: <20060816090028.GA25476@2ka.mipt.ru>
References: <20060814110359.GA27704@2ka.mipt.ru> <200608152221.22883.arnd@arndb.de> <20060816053545.GB22921@2ka.mipt.ru> <20060816084808.GA7366@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751038AbWHPJEd@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20060816084808.GA7366@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2006 at 09:48:08AM +0100, Christoph Hellwig (hch@infradead.org) wrote:
> > Doesn't alloc_pages() automatically switches to alloc_pages_node() or
> > alloc_pages_current()?
> 
> That's not what's wanted.  If you have a slow interconnect you always want
> to allocate memory on the node the network device is attached to.

There is drawback here - if data was allocated on CPU wheere NIC is
"closer" and then processed on different CPU it will cost more than 
in case where buffer was allocated on CPU where it will be processed.

But from other point of view, most of the adapters preallocate set of
skbs, and with msi-x help there will be a possibility to bind irq and
processing to the CPU where data was origianlly allocated.

So I would like to know how to determine which node should be used for
allocation. Changes of __get_user_pages() to alloc_pages_node() are
trivial.

-- 
	Evgeniy Polyakov
