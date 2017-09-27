From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 02/16] thunderbolt: Add support for XDomain properties
Date: Wed, 27 Sep 2017 16:06:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0082864@AcuExch.aculab.com>
References: <20170925110738.68382-1-mika.westerberg@linux.intel.com>
 <20170925110738.68382-3-mika.westerberg@linux.intel.com>
 <20170926.213354.305351416790211828.davem@davemloft.net>
 <20170927113241.GB4630@lahna.fi.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "andreas.noever@gmail.com" <andreas.noever@gmail.com>,
        "michael.jamet@intel.com" <michael.jamet@intel.com>,
        "yehezkel.bernat@intel.com" <yehezkel.bernat@intel.com>,
        "amir.jer.levy@intel.com" <amir.jer.levy@intel.com>,
        "Mario.Limonciello@dell.com" <Mario.Limonciello@dell.com>,
        "lukas@wunner.de" <lukas@wunner.de>,
        "andriy.shevchenko@linux.intel.com"
        <andriy.shevchenko@linux.intel.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Mika Westerberg' <mika.westerberg@linux.intel.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170927113241.GB4630@lahna.fi.intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mika Westerberg
> Sent: 27 September 2017 12:33
...
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

You've endianness considerations as well with on-wire formats.

__packed indicates two things:
1) There will be no padding bytes between fields.
2) The structure itself might appear on any byte boundary.

The latter causes the compiler to do byte memory accesses and
shifts to load/store the data on some architectures.
So only mark things __packed when they might be misaligned in
memory.

	David
