From: Craig Small <csmall@enc.com.au>
Subject: Re: r8169 won't transmit with 3.12
Date: Wed, 22 Jan 2014 15:00:52 +1100
Message-ID: <20140122040052.GA2310@enc.com.au>
References: <20140121000615.GA30495@enc.com.au>
 <20140121233630.GA3214@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:14730 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750809AbaAVEB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 23:01:59 -0500
Content-Disposition: inline
In-Reply-To: <20140121233630.GA3214@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If it helps, I know the tx_dropped is happening on line 5837 of r8169.c

			rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
					     tp->TxDescArray + entry);
			if (skb) {
				tp->dev->stats.tx_dropped++;
				dev_kfree_skb(skb);
				tx_skb->skb = NULL;
			}


On Wed, Jan 22, 2014 at 12:36:30AM +0100, Francois Romieu wrote:
> Craig Small <csmall@enc.com.au> :
> [...]
> > It's a new setup so it might of never worked. It's not likely to be a
> > hardware problem as its three different devices.
> 
> You may check that the onboard nic device does not even work when the
> extra PCI-e card aren't plugged.
> 
> > I've sent what I think you might need for starters, but if there
> > is extra stuff you'd like to see, let me know.
> 
> A complete dmesg including the XID lines that the r8169 driver prints
> would be welcome.
> 
> > The problem shows up the same, the TX dropped counter increments.
> > I'm not sure why 42 packets made it out (or even if they really did)
> > Receive works fine, I can even start up wireshark and see packets
> > pass by.
> > 
> > eth0      Link encap:Ethernet  HWaddr 00:e0:4c:80:66:57  
> >           inet addr:192.168.1.222  Bcast:192.168.1.255  Mask:255.255.255.0
> >           inet6 addr: fe80::2e0:4cff:fe80:6657/64 Scope:Link
> >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >           RX packets:8252 errors:0 dropped:0 overruns:0 frame:0
> >           TX packets:42 errors:0 dropped:8029 overruns:0 carrier:0
> 
> There are very few places where the r8169 driver modifies tx_dropped.
> 
> Please increase the driver verbosity with the 'msglvl' option of ethtool.
> 
> [...]
> > ethtool -S shows a similar story, not sure if the rx_missed counter
> > is another problem:
> 
> It seems safe to ignore as long as it does not change after startup.
> 
> -- 
> Ueimor

-- 
Craig Small (@smallsees)   http://enc.com.au/       csmall at : enc.com.au
Debian GNU/Linux           http://www.debian.org/   csmall at : debian.org
GPG fingerprint:        5D2F B320 B825 D939 04D2  0519 3938 F96B DF50 FEA5
