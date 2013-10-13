From: Romain Baeriswyl <Romain.Baeriswyl@abilis.com>
Subject: Re: [RFC] net: stmmac: keep RXC running in LPI mode to avoid system
 overload
Date: Sun, 13 Oct 2013 22:02:52 +0200 (CEST)
Message-ID: <808496140.2212.1381694572197.JavaMail.root@abilis.com>
References: <52557606.8030201@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Christian Ruppert <chrisr@abilis.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52557606.8030201@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Guiseppe,

Thanks for your answer. Please find below some details and answers.

> > In order to avoid system overload, the clock RXC from the Phy
> > should not be
> > stopped when in LPI mode.
> >
> > With the RTL8211E PHY which support EEE mode and with Apple Airport
> > Extreme that
> > supports it also, the kernel get frozen as soon as some Ethernet
> > transfers are
> 
> 
> hmm, I have a board with this transceiver so I could do some tests
> this could take a while, unfortunately.
> 
> > on-going. System seems to be overloaded with too many interrupts.
> > The 'top'
> > command reports often around ~80% irq.
> 
> do you mean lpi mac interrupts?
 
By disabling the LPI mode with ethtool --set-eee eth0 eee off, the 
interrupt overload remains. Both counters irq_rx_path_in_lpi_mode_n and 
irq_rx_path_exit_lpi_mode_n continue to run meaning the PHY continue
to put the RX path in LPI mode.

Only way I found to get ride of the overload is to keep the RX_CLK running
in LPI mode. In this configuration, the RX link still continue to go in
LPI mode and the two above counters continue to run.

> >
> > By letting the RXC clock running even in LPI mode as proposed
> > below, the issue
> > seems solved. Is it the right way to proceed?
> 
> For EEE capability, RX_CLK may be halted for this reason i used it as
> default in the stmmac and never seen your issue.
> 
> >
> > What is the power impact to not stop RXC in LPI mode?
> 
> I can point you to "22.2.2.8a Receive direction LPI transition"
> in IEEE802-3az... where is it reported that the PHY  halt the RX_CLK
> in LPI mode.

Actually the PHY "may" stop RX_CLK.

> 
> May I suspect some issues on your HW? or disable it with ethtool
> 

Yes, it could be HW issue. It would be very useful if you could reproduce 
the setup using a SoC with "DesignWare Cores Ethernet MAC" core, 
the RTL8211E PHY and an Apple Airport Extreme. The issue could well be between 
the controller and the PHY.

Which Ethernet switch or router did you use to test the EEE mode? 
I may try these equipments as well.

Romain
