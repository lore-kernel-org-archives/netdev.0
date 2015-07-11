From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2] net: dsa: mv88e6xxx: add write access to debugfs
 regs file
Date: Sat, 11 Jul 2015 14:36:12 -0400 (EDT)
Message-ID: <1092744390.7730.1436639772848.JavaMail.zimbra@savoirfairelinux.com>
References: <1436476409-5033-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20150710.230120.1590955832899872718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>, andrew@lunn.ch,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: David <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150710.230120.1590955832899872718.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Jul 11, 2015, at 2:01 AM, David davem@davemloft.net wrote:

> From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Date: Thu,  9 Jul 2015 17:13:29 -0400
> 
>> Allow write access to the regs file in the debugfs interface, with the
>> following parameters:
>> 
>>     echo <name> <reg> <value> > regs
>> 
>> Where "name" is the register name (as shown in the header row), "reg" is
>> the register address (as shown in the first column) and "value" is the
>> 16-bit value. e.g.:
>> 
>>     echo GLOBAL 1a 5550 > regs
>> 
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> I don't know about this.
> 
> This starts to smell like a back door for proprietary userspace SDKs to
> program the switch hardware.
> 
> Yes, they can do it via other mechanisms, but we don't have to make it
> any eaiser for them either.

I agree with you and I wouldn't want that neither.

> If you want to poke registers, hack the module just like any other
> person with appropriate privileges can do.

I'm not sure what you mean. Keeping some custom patches in our local tree?

> Frankly, all of this debugfs crap in the DSA drivers smells like poo.
> I don't like it _AT_ _ALL_, and I shouldn't have allowed any of it
> into the tree in the first place.
> 
> I might just remove it all myself, it bothers me so much.
> 
> Fetching information should be done by well typed, generic, interfaces
> that apply to any similar device or object.  All of this debugfs stuff
> smells of hacks and special case crap that's only usable for one
> device type and that makes it the single most terrible interface to
> give to users.

In the meantime, this is really useful for development. i.e. ensuring a good
switchdev/DSA interaction without being able to read and write directly the
hardware VLAN table, is a bit a PITA. A dynamic debugfs looked appropriate.

On the other hand, the mv88e6xxx driver gets cluttered with all this code. I'd
gladly move all this code in a mv88e6xxx-debugfs.c file, and conditionally
compile it with:

    mv88e6xxx_drv-$(CONFIG_DEBUG_FS) += mv88e6xxx-debugfs.o

similar to what the i2400m driver does.

Would that be appreciated?

Thanks,
-v
