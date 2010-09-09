From: Michael Williamson <michael.williamson@criticallink.com>
Subject: Re: [PATCH v3 00/10] split out emac cpdma and mdio for reuse
Date: Wed, 08 Sep 2010 20:47:38 -0400
Message-ID: <4C882EAA.9030903@criticallink.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com> <871v95f2xv.fsf@deeprootsystems.com> <4C86F369.6040906@criticallink.com> <4C880733.5010909@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Kevin Hilman <khilman@deeprootsystems.com>,
	"tony@atomide.com" <tony@atomide.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: cyril@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:44410 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342Ab0IIArm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 20:47:42 -0400
In-Reply-To: <4C880733.5010909@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cyril,

On 09/08/2010 05:59 PM, Cyril Chemparathy wrote:
> Hi Mike,
> 
> [...]
>> So I just pulled this to test it out on a da850 based board
>> (mitydspl138), and I'm having some problems.  I'm hoping it's just
>> operator error.
> 
> Probably not, considering that this series had not been tested on da8xx
> platforms.  Thanks for jumping in!
> 

Jumped, pushed, you say tomato, ... ;^)

>> I have a TI TLK100PHP PHY at address 0x3.  The boot log shows:
>>
>> [snip]
>> davinci_mdio davinci_mdio.0: davinci mdio revision 1.5
>> davinci_mdio davinci_mdio.0: detected phy mask fffffff7
>> davinci_mdio.0: probed
>> davinci_mdio davinci_mdio.0: phy[3]: device 0:03, driver unknown
>> [snip]
> 
> So far so good.  The MDIO code seems to have done its part and latched
> on to the correct phy.  To answer your question from below, the "driver
> unknown" implies that the generic phy driver has been attached to the
> detected phy.
> 
>> and then in the init scripts, following udev population I get a 
>> "Configuring network interfaces... "
>>
>> and the boot process just hangs.
> 
> Not a peep from emac? Strange.
> 

So I went in and set the debug_level to netif_msg_init() to -1 in the davinci_emac
driver.  The only thing I get during the boot process is:

net eth0: DaVinci EMAC Probe found device (regs: 01e23000, irq: 33)

which is good (I also added some debug to make sure probe actually completes), but
I don't see *anything* else.  I guess I would have expected to see something out of 
the emac_dev_open.  So I added some more debug in there, it's hanging in the 
phy_connect() call.  The phy_id it came up with was correct "0:03".


[snip]
> 
> I spent some time today on testing this series on a da830 evm board
> (sorry, couldn't manage to scrounge up a da850 platform).  In the
> process, I have had to put in some fixes, particularly for the
> phy-association piece.  You can preview these commits on my repo's
> gitweb [1].
> 

I did apply the requeue on early end-of-queue patch.  No difference, which is not
surprising as it's dying in the phy_connect.  I don't think I need the others, 
as the correct phy_id is being located by the MDIO probe headed
into the phy_connect call (pointer is valid, string is OK, etc.).  If I have time I
can continue to poke around, but I'm really not up on this chunk of code...

-Mike


