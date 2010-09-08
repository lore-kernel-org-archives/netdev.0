From: Michael Williamson <michael.williamson@criticallink.com>
Subject: Re: [PATCH v3 00/10] split out emac cpdma and mdio for reuse
Date: Tue, 07 Sep 2010 22:22:33 -0400
Message-ID: <4C86F369.6040906@criticallink.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com> <871v95f2xv.fsf@deeprootsystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Cyril Chemparathy <cyril@ti.com>, tony@atomide.com,
	netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org, davem@davemloft.net
To: Kevin Hilman <khilman@deeprootsystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:37172 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871Ab0IHCWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 22:22:36 -0400
In-Reply-To: <871v95f2xv.fsf@deeprootsystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2010 09:18 PM, Kevin Hilman wrote:
> Cyril Chemparathy <cyril@ti.com> writes:
> 
>> Davinci's EMAC device has an in-built MDIO controller and a CPDMA engine.
>> These hardware modules are not restricted to EMAC device alone.  For example,
>> CPSW3G (3-port gigabit ethernet switch) hardware uses these very same modules
>> internally.  This patch series separates out EMAC's MDIO and CPDMA
>> functionality, allowing these individual pieces to be reused across TI
>> hardware.  
> 
> OK, queuing this series for 2.6.37 in davinci-next.
> 

So I just pulled this to test it out on a da850 based board (mitydspl138), and I'm having
some problems.  I'm hoping it's just operator error.

I have a TI TLK100PHP PHY at address 0x3.  The boot log shows:

[snip]
davinci_mdio davinci_mdio.0: davinci mdio revision 1.5
davinci_mdio davinci_mdio.0: detected phy mask fffffff7
davinci_mdio.0: probed
davinci_mdio davinci_mdio.0: phy[3]: device 0:03, driver unknown
[snip]

and then in the init scripts, following udev population I get a 
"Configuring network interfaces... "

and the boot process just hangs.

I went back and did a menuconfig, I didn't see an option for TI PHY support, but
shouldn't there be a "generic" PHY driver that defaults if one isn't matched?  I 
do have TI DaVinci EMAC/MDIO/CPDMA support enabled under the Ethernet (10 or 100 Mbit).

Anyway, I've only looked at this for about 15 minutes, and I was hoping anyone might 
point out something obvious.  If there are hints anyone might have for debugging, I'd
appreciate them as well.  Or, if anyone has tested this with a da850 evm, that would 
point me to a problem in the board file.

Thanks for any insight.

-Mike


