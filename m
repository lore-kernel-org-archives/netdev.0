From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: Re: [PATCH v2 16/16] net: Add support for networking over
 Thunderbolt cable
Date: Wed, 27 Sep 2017 20:27:02 +0300
Message-ID: <20170927172702.GE4630@lahna.fi.intel.com>
References: <20170925110738.68382-17-mika.westerberg@linux.intel.com>
 <20170926.214721.734746621809140934.davem@davemloft.net>
 <20170927134238.GC4630@lahna.fi.intel.com>
 <20170927.092709.1826177647592316221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org, andreas.noever@gmail.com,
        michael.jamet@intel.com, yehezkel.bernat@intel.com,
        amir.jer.levy@intel.com, Mario.Limonciello@dell.com,
        lukas@wunner.de, andriy.shevchenko@linux.intel.com, andrew@lunn.ch,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170927.092709.1826177647592316221.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2017 at 09:27:09AM -0700, David Miller wrote:
> From: Mika Westerberg <mika.westerberg@linux.intel.com>
> Date: Wed, 27 Sep 2017 16:42:38 +0300
> 
> > Using build_skb() then would require to allocate larger buffer, that
> > includes NET_SKB_PAD + SKB_DATA_ALIGN(skb_shared_info) and that exceeds
> > page size. Is this something supported by build_skb()? It was not clear
> > to me based on the code and other users of build_skb() but I may be
> > missing something.
> 
> You need NET_SKB_PAD before and SKB_DATA_ALIGN(skb_shared_info) afterwards.
> An order 1 page, if that's what you need, should work just fine.

I mean in order to fit a single ThunderboltIP frame, I would need to
allocate NET_SKB_PAD+4096+SKB_DATA_ALIGN(skb_shared_info) size buffer.
Is that still fine for build_skb()? Also can I use that with
skb_add_rx_frag() which seem to take single page?

ThunderboltIP protocol basically takes advantage of TSO/LRO but it
actually does not do any segmentation. Instead it just splits the 64kB
large package into smaller 4k frames (which each include 12 byte header)
and pushes those over the Thunderbolt medium. The receiver side then
does the opposite.

Thanks and sorry for dummy questions. I'm just not too familiar with
the networking subsystem (yet).
