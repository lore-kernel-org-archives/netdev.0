From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: dsa: mv88e6xxx: add write access to debugfs
 regs file
Date: Fri, 10 Jul 2015 23:01:20 -0700 (PDT)
Message-ID: <20150710.230120.1590955832899872718.davem@davemloft.net>
References: <1436476409-5033-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@roeck-us.net, andrew@lunn.ch,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436476409-5033-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu,  9 Jul 2015 17:13:29 -0400

> Allow write access to the regs file in the debugfs interface, with the
> following parameters:
> 
>     echo <name> <reg> <value> > regs
> 
> Where "name" is the register name (as shown in the header row), "reg" is
> the register address (as shown in the first column) and "value" is the
> 16-bit value. e.g.:
> 
>     echo GLOBAL 1a 5550 > regs
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

I don't know about this.

This starts to smell like a back door for proprietary userspace SDKs to
program the switch hardware.

Yes, they can do it via other mechanisms, but we don't have to make it
any eaiser for them either.

If you want to poke registers, hack the module just like any other
person with appropriate privileges can do.

Frankly, all of this debugfs crap in the DSA drivers smells like poo.
I don't like it _AT_ _ALL_, and I shouldn't have allowed any of it
into the tree in the first place.

I might just remove it all myself, it bothers me so much.

Fetching information should be done by well typed, generic, interfaces
that apply to any similar device or object.  All of this debugfs stuff
smells of hacks and special case crap that's only usable for one
device type and that makes it the single most terrible interface to
give to users.

Thanks.
