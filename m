From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: RE: packetloss, on e1000e worse than r8169?
Date: Tue, 17 Jun 2008 04:53:47 +0300
Message-ID: <20080617014849.M77611@visp.net.lb>
References: <20080616193501.M64730@visp.net.lb> <4856C3A7.9070703@cosmosbay.com> <20080616202210.M84100@visp.net.lb> <4856CEDC.6010706@intel.com> <20080616204411.M52834@visp.net.lb> <4856D1D6.7040207@intel.com> <20080616211213.M76390@visp.net.lb> <4856DB1D.80503@cosmosbay.com> <20080616213419.M212@visp.net.lb> <4856DE1F.4090001@cosmosbay.com> <4856DEA7.9060506@cosmosbay.com> <20080616220841.M50112@visp.net.lb> <36D9DB17C6DE9E40B059440DB8D95F52056AC4C2@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:40301 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbYFQBxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 21:53:55 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52056AC4C2@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jun 2008 16:24:22 -0700, Brandeburg, Jesse wrote
> 
> error stats update only every two seconds from e1000e watchdog timer.
> 
> Please try using ethtool -C ethX rx-usecs 10 (100,000 interrupts per
> second possible)
> 
> The realtek may not have the same kind of interrupt moderation as the
> e1000e part.  Also, you mentioned elsewhere in this thread that PCIe
> should have plenty of bandwith but the reality is that x1 PCIe has a 
> lot of latency so as you try to push a lot of small packets they may 
> not be processed fast enough.
> 
> Try turning off Flow Control using ethtool -A ethX rx off tx off autoneg
> off
> 
> rx_missed_errors is because you're running out of RX FIFO in the
> adapter, and we can try to change some code to increase the RX fifo 
> to a larger value, if you're using default 1500 MTU, you only need 
> 4K TX fifo, so can have a little more RX fifo than what you have by default
> (it's the PBA register we need to change the lower 16 bits to 0x1c)
> 
> Jesse
First of all thanks for all efforts and help you gave me guys. I wish i can
solve this problem and probably it will help someone in future. Sure i can
easily put server with PCI-X e1000, but probably it is good idea to find bug,
if there is any.

Now i changed motherboard, to another one (without AMT), same family and same
e1000e onboard.
Now it is DG965SS.

I will try to play with flow control and interrupt moderation on it.

By the way, i have ICH8, is there anything i can hit because of it?
i notice
        /* Workaround for ICH8 bit corruption issue in FIFO memory */
        if (hw->mac.type == e1000_ich8lan) {
                /* Set Tx and Rx buffer allocation to 8k apiece. */
                ew32(PBA, E1000_PBA_8K);
                /* Set Packet Buffer Size to 16k. */
                ew32(PBS, E1000_PBS_16K);
        }


About PBA, is i need to change something here?
                /*
                 * the Tx fifo also stores 16 bytes of information about the tx
                 * but don't include ethernet FCS because hardware appends it
                 */
                min_tx_space = (adapter->max_frame_size +
                                sizeof(struct e1000_tx_desc) -
                                ETH_FCS_LEN) * 2;
                min_tx_space = ALIGN(min_tx_space, 1024);
                min_tx_space >>= 10;
                /* software strips receive CRC, so leave room for it */
                min_rx_space = adapter->max_frame_size;
                min_rx_space = ALIGN(min_rx_space, 1024);
                min_rx_space >>= 10;


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

