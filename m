From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: Re: [PATCH v2 02/16] thunderbolt: Add support for XDomain properties
Date: Wed, 27 Sep 2017 14:32:41 +0300
Message-ID: <20170927113241.GB4630@lahna.fi.intel.com>
References: <20170925110738.68382-1-mika.westerberg@linux.intel.com>
 <20170925110738.68382-3-mika.westerberg@linux.intel.com>
 <20170926.213354.305351416790211828.davem@davemloft.net>
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
In-Reply-To: <20170926.213354.305351416790211828.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 26, 2017 at 09:33:54PM -0700, David Miller wrote:
> From: Mika Westerberg <mika.westerberg@linux.intel.com>
> Date: Mon, 25 Sep 2017 14:07:24 +0300
> 
> > +struct tb_property_entry {
> > +	u32 key_hi;
> > +	u32 key_lo;
> > +	u16 length;
> > +	u8 reserved;
> > +	u8 type;
> > +	u32 value;
> > +} __packed;
> > +
> > +struct tb_property_rootdir_entry {
> > +	u32 magic;
> > +	u32 length;
> > +	struct tb_property_entry entries[];
> > +} __packed;
> > +
> > +struct tb_property_dir_entry {
> > +	u32 uuid[4];
> > +	struct tb_property_entry entries[];
> > +} __packed;
> 
> There is no apparent need for __packed here, and __packed should be
> avoided unless absolutely necessary as it pessimizes the code
> significantly on some architectures.
> 
> Please remove __packed from these datastructures unless you can
> prove it is absolutely needed and, in such case, please document
> in a comment why that requirement exists.  Because from the layout
> of these types, everything will be packed in just fine without
> __packed.

I will thanks.

Just for my education, is there some rule which tells when __packed is
to be used? For example the above structures are all 32-bit aligned but
how about something like:

struct foo {
	u32 value1;
	u8 value2;
};

If the on-wire format requires such structures I assume __packed
is needed here?

Thanks!
