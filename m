From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 7/7] net: dsa: mv88e6xxx: drop switch id
Date: Fri, 15 Apr 2016 23:51:57 +0200
Message-ID: <20160415215157.GB26665@lunn.ch>
References: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1460744750-13896-8-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20160415193818.GE18523@lunn.ch>
 <87k2jya8ot.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87k2jya8ot.fsf@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 15, 2016 at 05:00:50PM -0400, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> <snip>
> 
> >> -#define PORT_SWITCH_ID_6350	0x3710
> >> -#define PORT_SWITCH_ID_6351	0x3750
> >> -#define PORT_SWITCH_ID_6352	0x3520
> >
> > NACK
> >
> > These numbers are not obvious. PORT_SWITCH_ID_6320 i can
> > understand. 0x1150 i have no idea what it is.
> 
> 0x1150 is not even correct. That's the product number (bits 4:15) masked
> with an assumed revision 0 (bits 0:3).
> 
> That leads to confusion and error, as seen in the patch 2/7.
> 
> These values are now only used in a device description table, where they
> seem pretty understandable to me.

      { MV88E6XXX_INFO(6320, 0x115, "Marvell 88E6320") },
      { MV88E6XXX_INFO(6320, 0x310, "Marvell 88E6321") },

What does 0x115 have to do with 6320?
What does 0x310 have to do with 6321?

Most do have a pattern, but not all. For a few devices, Marvell has
used /dev/random to pick the ID. Using the macro PORT_SWITCH_ID_6320
documents where these numbers come from, and how to figure out the
correct number of a new device, etc.

> But OK if we really want them defined, I'll introduce 12-bit
> PORT_SWITCH_ID_PROD_NUM_* before dropping the 16-bit
> PORT_SWITCH_ID_*.

I'm O.K. with that.

Thanks
	Andrew
