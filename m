From: Jirka Bohac <jbohac@suse.cz>
Subject: Re: ipw2100: firmware problem
Date: Wed, 8 Jun 2005 16:56:53 +0200
Message-ID: <20050608145653.GA8844@dwarf.suse.cz>
References: <20050608142310.GA2339@elf.ucw.cz> <200506081744.20687.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Machek <pavel@ucw.cz>, Jeff Garzik <jgarzik@pobox.com>,
	Netdev list <netdev@oss.sgi.com>,
	kernel list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261305AbVFHPLR@vger.kernel.org>
To: Denis Vlasenko <vda@ilport.com.ua>
Content-Disposition: inline
In-Reply-To: <200506081744.20687.vda@ilport.com.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 08, 2005 at 05:44:20PM +0300, Denis Vlasenko wrote:
> On Wednesday 08 June 2005 17:23, Pavel Machek wrote:
> > What's the prefered way to solve this one? Only load firmware when
> > user does ifconfig eth1 up? [It is wifi, it looks like it would be
> > better to start firmware sooner so that it can associate to the
> > AP...].
> 
> Do you want to associate to an AP when your kernel boots,
> _before_ any iwconfig had a chance to configure anything?
> That's strange.
> 
> My position is that wifi drivers must start up in an "OFF" mode.
> Do not send anything. Do not join APs or start IBSS.

Agreed.

> Thus, no need to load fw in early boot.

I don't think this is true. Loading the firmware on the first
"ifconfig up" is problematic. Often, people want to rename the
device from ethX/wlanX/... to something stable. This is usually
based on the adapter's MAC address, which is not visible until
the firmware is loaded.

Prism54 does it this way and it really sucks. You need to bring
the adapter up to load the firmware, then bring it back down,
rename it, and bring it up again.

Denis: any plans for this to be fixed?

I agree that drivers should initialize the adapter in the OFF
state, but the firmware needs to be loaded earlier than the
first ifconfig up.

How about loading the firmware when the first ioctl touches the
device? This way, it would get loaded just before the MAC address
is retrieved.

regards,

-- 
Jirka Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CR
