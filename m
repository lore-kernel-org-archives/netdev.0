From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 02/16] thunderbolt: Add support for XDomain
 properties
Date: Wed, 27 Sep 2017 09:22:16 -0700 (PDT)
Message-ID: <20170927.092216.1164977518037321262.davem@davemloft.net>
References: <20170925110738.68382-3-mika.westerberg@linux.intel.com>
        <20170926.213354.305351416790211828.davem@davemloft.net>
        <20170927113241.GB4630@lahna.fi.intel.com>
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
In-Reply-To: <20170927113241.GB4630@lahna.fi.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mika Westerberg <mika.westerberg@linux.intel.com>
Date: Wed, 27 Sep 2017 14:32:41 +0300

> Just for my education, is there some rule which tells when __packed is
> to be used? For example the above structures are all 32-bit aligned but
> how about something like:
> 
> struct foo {
> 	u32 value1;
> 	u8 value2;
> };
> 
> If the on-wire format requires such structures I assume __packed
> is needed here?

Usually header elements are 32-bit aligned in a protocol, so it wouldn't
be specified like that.

The only legitimate case I've seen is where things are purposefully
misaligned within the header, like this:

struct foo {
	u16	x;
	u64	y;
	u16	z;
};

Where the 'y' element is 2-byte aligned.

Fortunately, those situations are extremely rare.
