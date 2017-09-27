From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 16/16] net: Add support for networking over
 Thunderbolt cable
Date: Wed, 27 Sep 2017 11:23:17 -0700 (PDT)
Message-ID: <20170927.112317.1120325676502363972.davem@davemloft.net>
References: <20170927134238.GC4630@lahna.fi.intel.com>
        <20170927.092709.1826177647592316221.davem@davemloft.net>
        <20170927172702.GE4630@lahna.fi.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, andreas.noever@gmail.com,
        michael.jamet@intel.com, yehezkel.bernat@intel.com,
        amir.jer.levy@intel.com, Mario.Limonciello@dell.com,
        lukas@wunner.de, andriy.shevchenko@linux.intel.com, andrew@lunn.ch,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mika.westerberg@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170927172702.GE4630@lahna.fi.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mika Westerberg <mika.westerberg@linux.intel.com>
Date: Wed, 27 Sep 2017 20:27:02 +0300

> On Wed, Sep 27, 2017 at 09:27:09AM -0700, David Miller wrote:
>> From: Mika Westerberg <mika.westerberg@linux.intel.com>
>> Date: Wed, 27 Sep 2017 16:42:38 +0300
>> 
>> > Using build_skb() then would require to allocate larger buffer, that
>> > includes NET_SKB_PAD + SKB_DATA_ALIGN(skb_shared_info) and that exceeds
>> > page size. Is this something supported by build_skb()? It was not clear
>> > to me based on the code and other users of build_skb() but I may be
>> > missing something.
>> 
>> You need NET_SKB_PAD before and SKB_DATA_ALIGN(skb_shared_info) afterwards.
>> An order 1 page, if that's what you need, should work just fine.
> 
> I mean in order to fit a single ThunderboltIP frame, I would need to
> allocate NET_SKB_PAD+4096+SKB_DATA_ALIGN(skb_shared_info) size buffer.

Which would be an order 1 page or 8192 bytes.

> Is that still fine for build_skb()? Also can I use that with
> skb_add_rx_frag() which seem to take single page?

Again, an order 1 page should work fine.
