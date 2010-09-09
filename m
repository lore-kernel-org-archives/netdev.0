From: Michael Williamson <michael.williamson@criticallink.com>
Subject: Re: [PATCH v3 00/10] split out emac cpdma and mdio for reuse
Date: Thu, 09 Sep 2010 17:45:44 -0400
Message-ID: <4C895588.3060500@criticallink.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com>	<871v95f2xv.fsf@deeprootsystems.com>	<4C86F369.6040906@criticallink.com> <4C880733.5010909@ti.com>	<4C882EAA.9030903@criticallink.com>	<4C892AC0.80409@criticallink.com> <4C893ADE.809@ti.com> <4C89507E.9040407@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tony@atomide.com" <tony@atomide.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: cyril@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <4C89507E.9040407@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/09/2010 05:24 PM, Cyril Chemparathy wrote:
> Hi Mike,
> 
> [...]
>> An EMAC soft-reset clobbering the MDIO controller state is a
>> possibility.  I will poll TI designers to see if this could be the case.
> 
> To test this theory out, I hacked up a crude
> beat-it-to-death-and-see-if-it-breaks kinda patch (attached).  This
> tests 10000 mdio read cycles while constantly doing an emac soft-reset.
> 
> I ran this on a dm365 evm, and the test didn't raise a single failed read:
>> davinci_mdio davinci_mdio.0: davinci mdio revision 1.4
>> davinci_mdio davinci_mdio.0: detected phy mask fffffffc
>> 10000 test loops completed, 10000 reads ok
> 
> The failure in question seems to be limited to the da8xx family (tested
> da830 evm), where:
>> davinci_mdio davinci_mdio.0: davinci mdio revision 1.5
>> davinci_mdio davinci_mdio.0: detected phy mask fffffff1
>> idle triggered!!
> 
> The MDIO module upgrade (rev 1.4 -> 1.5) could have something to do with
> this behavior.  Even so, I can't explain why this issue wasn't seen on
> da8xx prior to this series.  The original code should (at least in
> theory) have sporadically locked up on emac open.
> 

I think, if I understand it correctly, that in the previous version of 
this code, the emac was reset *prior* to enabling, scanning, and assigning 
the associated phy on the MDIO bus.  The new implementation sets up and scans 
the MDIO bus first, then comes back around to the EMAC second... hits a reset,
and doesn't re-ENABLE the MDIO.

Also, maybe hitting the EMAC reset while the MDIO state machine is up is *bad*, I 
seem to recall some text in the user's guide about waiting for the state
machine to stop before disabling it.  I wonder if that also applies to reset?

-Mike
