From: Sebastien Jan <s-jan@ti.com>
Subject: Re: [PATCH 4/4 v2] ks8851: read/write MAC address on companion eeprom through debugfs
Date: Thu, 6 May 2010 10:01:49 +0200
Message-ID: <201005061001.49747.s-jan@ti.com>
References: <1273085155-1260-1-git-send-email-s-jan@ti.com> <1273085155-1260-5-git-send-email-s-jan@ti.com> <20100506.002508.241926083.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"Arce, Abraham" <x0066660@ti.com>,
	"ben-linux@fluff.org" <ben-linux@fluff.org>,
	"Tristram.Ha@micrel.com" <Tristram.Ha@micrel.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20100506.002508.241926083.davem@davemloft.net>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi david,

On Thursday 06 May 2010 09:25:08 David Miller wrote:
> From: Sebastien Jan <s-jan@ti.com>
> Date: Wed,  5 May 2010 20:45:55 +0200
> 
> > A more elegant alternative to ethtool for updating the ks8851
> > MAC address stored on its companion eeprom.
> > Using this debugfs interface does not require any knowledge on the
> > ks8851 companion eeprom organization to update the MAC address.
> >
> > Example to write 01:23:45:67:89:AB MAC address to the companion
> > eeprom (assuming debugfs is mounted in /sys/kernel/debug):
> > $ echo "01:23:45:67:89:AB" > /sys/kernel/debug/ks8851/mac_eeprom
> >
> > Signed-off-by: Sebastien Jan <s-jan@ti.com>
> 
> Elegant?  This commit message is the biggest lie ever told.
> 
> What makes your ethernet driver so god-damn special that it deserves
> to have a private, completely unique, and obscure interface for
> setting the permanent ethernet address of a network device?
> 
> Tell me how damn elegant it is that users have to learn about this
> special, unique, and common with no other driver, interface for
> performing this task?
> 
> Tell me how damn elegant it is when another driver wants to provide
> users with a way to do this too, and they (like you) come up with
> their own unique and different interface for doing this.
> 
> No, this is the most inelegant patch ever conceived because it totally
> ignores the way in which we handle issues like this.
> 
> There is no way in the world I'm applying this garbage patch, sorry.
> 
> We have an ETHTOOL_GPERMADDR, add a new ETHTOOL_SPERMADDR operation
> and then any driver (not just your's) can portably provide this
> facility and users will have one, and only one, way of performing this
> task.
> 

I agree that my commit message was probably too provocative, sorry for that.

Thank you for shedding some light on ETHTOOL_GPERMADDR and ETHTOOL_SPERMADDR. 
I will look into these interfaces for a proper and generic implementation.
