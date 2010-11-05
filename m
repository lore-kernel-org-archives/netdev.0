From: David <david@unsolicited.net>
Subject: Sky2 - problems with VLANs - kernel 2.6.36
Date: Fri, 05 Nov 2010 23:06:14 +0000
Message-ID: <4CD48DE6.7060906@unsolicited.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've just installed a Lycom dual port gigabit ethernet card, picked up
as follows :-

03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8062 PCI-E
IPMI Gigabit Ethernet Controller (rev 14)
    Subsystem: Marvell Technology Group Ltd. Device 6222
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 41
    Region 0: Memory at fe8fc000 (64-bit, non-prefetchable) [size=16K]
    Region 2: I/O ports at c800 [size=256]
    Expansion ROM at fe8c0000 [disabled] [size=128K]
    Capabilities: <access denied>
    Kernel driver in use: sky2
    Kernel modules: sky2

I'm having a problem with VLANs. Outgoing packets are tagged correctly
and devices on the VLAN are responding. Unfortunately all of the
response packets stay on the raw device and are not allocated to the VLAN.

I've done some investigation (printks etc.), and have found that neither
of the following cases in sky2_status_intr() are being triggered...

                case OP_RXVLAN:
                        printk("RXVLAN, length=%u, status=%u\n", length,
status);
                        sky2->rx_tag = length;
                        break;

                case OP_RXCHKSVLAN:
                        printk("RXCHKSVLAN, length=%u, status=%u\n",
length, status);
                        sky2->rx_tag = length;
                        /* fall through */

... however the status when calling sky2_skb_rx() does have GMR_FS_VLAN
set, it's just we haven't been able to find out which VLAN the packet
comes from (and sky2->rx_tag is zero). Does anyone have any suggestions
as to how I proceed from here? I'm happy to test patches etc.

Cheers
David
