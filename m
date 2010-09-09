From: Michael Williamson <michael.williamson@criticallink.com>
Subject: Re: [PATCH v3 00/10] split out emac cpdma and mdio for reuse
Date: Thu, 09 Sep 2010 14:43:12 -0400
Message-ID: <4C892AC0.80409@criticallink.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com> <871v95f2xv.fsf@deeprootsystems.com> <4C86F369.6040906@criticallink.com> <4C880733.5010909@ti.com> <4C882EAA.9030903@criticallink.com>
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
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <4C882EAA.9030903@criticallink.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/8/2010 8:47 PM, Michael Williamson wrote:

> Hi Cyril,
> 
> On 09/08/2010 05:59 PM, Cyril Chemparathy wrote:
>> Hi Mike,
>>
> 
> So I went in and set the debug_level to netif_msg_init() to -1 in the davinci_emac
> driver.  The only thing I get during the boot process is:
> 
> net eth0: DaVinci EMAC Probe found device (regs: 01e23000, irq: 33)
> 
> which is good (I also added some debug to make sure probe actually completes), but
> I don't see *anything* else.  I guess I would have expected to see something out of 
> the emac_dev_open.  So I added some more debug in there, it's hanging in the 
> phy_connect() call.  The phy_id it came up with was correct "0:03".
> 
> 


The hang is in wait_for_user_access() in the davinci_mdio_read() call.  Looks like
the state machine got put back into IDLE somewhere between the MDIO probe and the 
EMAC probe. Seems like there should be some sort of time-out and error message 
in the wait_for_user_access() method.... (maybe even a check for IDLE??)

If I add a patch to check the state machine for IDLE and then re-enable it in the
davinci_mdio_read() call, it is able to press on and come up.  I don't see any calls
to the davinci_mdio_suspend() call, so I am wondering if the EMAC probe routine, 
particularly the application of the SOFTRESET, is causing the MDIO to drop back to 
IDLE / disabled.

I can post the patch if you like, but it is a bit of a hack...

-Mike
