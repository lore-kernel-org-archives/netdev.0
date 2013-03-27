From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Wed, 27 Mar 2013 23:02:48 +0100
Message-ID: <20130327220248.GD23223@order.stressinduktion.org>
References: <20130324043738.GD17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CCD@nasanexd02f.na.qualcomm.com> <20130324051325.GE17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CFC@nasanexd02f.na.qualcomm.com> <20130324052300.GA12968@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7D1E@nasanexd02f.na.qualcomm.com> <20130326042700.GC29705@order.stressinduktion.org> <157393863283F442885425D2C4542856489E821B@nasanexd02f.na.qualcomm.com> <20130326044025.GD29705@order.stressinduktion.org> <157393863283F442885425D2C4542856489E8232@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sven Hartge <sven@svenhartge.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35003 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752885Ab3C0WCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 18:02:49 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C4542856489E8232@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 26, 2013 at 04:44:50AM +0000, Huang, Xiong wrote:
> You can try to get windows register setting by
> 
> Pci config space register 0x80/0x84
> For example, to read register 0x1480
> Pci configure write 0x1480 to [0x80] (32bit)
> Pci configure read [0x84]
> 
> Only 32 bit read/write is allowed.

Here we go. In Linux we reread the registers with the same method, again.
Perhaps you can see something:


                      Register   Reg-Num        Linux      Windows          XOR
-------------------------------------------------------------------------------
           REG_BASE_CPU_NUMBER    0x157c          0x0          0x0          0x0
                REG_BIST0_CTRL    0x141c          0x0          0x0          0x0
                REG_BIST1_CTRL    0x1420          0x0          0x0          0x0
           REG_CMBDISDMA_TIMER    0x140e   0xc3503c01   0xffff1c01   0x3caf2000
               REG_DEBUG_DATA0    0x1900       0x1000       0x1f2f        0xf2f
               REG_DEBUG_DATA1    0x1904   0x90004800          0x0   0x90004800
         REG_DESC_BASE_ADDR_HI    0x1540          0x0          0x0          0x0
                REG_DEVICE_CAP      0x5c     0x647f85     0x647f85          0x0
               REG_DEVICE_CTRL      0x60     0x1a2000     0x112000      0xb0000
                  REG_DMA_CTRL    0x15c0     0x247c24     0x247c54         0x70
                 REG_GPHY_CTRL    0x140c   0xc3503c01   0xffff1c01   0x3caf2000
          REG_HOST_RXF0_MB0_LO    0x1820   0xcf981404   0xa72c8510   0x68b49114
          REG_HOST_RXF0_MB1_LO    0x1824   0xcf981408   0xa7308c20   0x68a89828
        REG_HOST_RXF0_PAGE0_LO    0x1544   0xcf900800   0xa72c8600   0x68bc8e00
       REG_HOST_RXF0_PAGE0_VLD    0x15f4    0x1010101       0x1b19    0x1011a18
        REG_HOST_RXF0_PAGE1_LO    0x1548   0xcf940e00   0xa7308d00   0x68a48300
       REG_HOST_RXF0_PAGE1_VLD    0x15f5    0x1010101       0x1b19    0x1011a18
         REG_HOST_RXF0_PAGEOFF    0x1800      0x2e640    0xc01de00    0xc033840
          REG_HOST_RXF1_MB0_LO    0x1828          0x0          0x0          0x0
          REG_HOST_RXF1_MB1_LO    0x182c          0x0          0x0          0x0
        REG_HOST_RXF1_PAGE0_LO    0x15d0          0x0          0x0          0x0
       REG_HOST_RXF1_PAGE0_VLD    0x15f6    0x1010101       0x1b19    0x1011a18
        REG_HOST_RXF1_PAGE1_LO    0x15d4          0x0          0x0          0x0
       REG_HOST_RXF1_PAGE1_VLD    0x15f7    0x1010101       0x1b19    0x1011a18
         REG_HOST_RXF1_PAGEOFF    0x1808          0x0          0x0          0x0
          REG_HOST_RXF2_MB0_LO    0x1830          0x0          0x0          0x0
          REG_HOST_RXF2_MB1_LO    0x1834          0x0          0x0          0x0
        REG_HOST_RXF2_PAGE0_LO    0x15d8          0x0          0x0          0x0
       REG_HOST_RXF2_PAGE0_VLD    0x15f8    0x1010101          0x0    0x1010101
        REG_HOST_RXF2_PAGE1_LO    0x15dc          0x0          0x0          0x0
       REG_HOST_RXF2_PAGE1_VLD    0x15f9    0x1010101          0x0    0x1010101
         REG_HOST_RXF2_PAGEOFF    0x180c          0x0          0x0          0x0
          REG_HOST_RXF3_MB0_LO    0x1838          0x0          0x0          0x0
          REG_HOST_RXF3_MB1_LO    0x183c          0x0          0x0          0x0
        REG_HOST_RXF3_PAGE0_LO    0x15e0          0x0          0x0          0x0
       REG_HOST_RXF3_PAGE0_VLD    0x15fa    0x1010101          0x0    0x1010101
        REG_HOST_RXF3_PAGE1_LO    0x15e4          0x0          0x0          0x0
       REG_HOST_RXF3_PAGE1_VLD    0x15fb    0x1010101          0x0    0x1010101
         REG_HOST_RXF3_PAGEOFF    0x1810          0x0          0x0          0x0
         REG_HOST_RXFPAGE_SIZE    0x1558      0x40000      0x40000          0x0
          REG_HOST_SMB_ADDR_LO    0x1844          0x0          0x0          0x0
            REG_HOST_TX_CMB_LO    0x1840   0xcf981400   0xcff75000     0x6f4400
               REG_IDLE_STATUS    0x1410          0x0          0x0          0x0
                REG_IDT_TABLE0    0x1560          0x0   0xe4e4e4e4   0xe4e4e4e4
                REG_IDT_TABLE1    0x1564   0xe4e4e4e4   0xe4e4e4e4          0x0
                REG_IDT_TABLE2    0x1568   0xe4e4e4e4   0xe4e4e4e4          0x0
                REG_IDT_TABLE3    0x156c   0xe4e4e4e4   0xe4e4e4e4          0x0
                REG_IDT_TABLE4    0x14e0   0xe4e4e4e4   0xe4e4e4e4          0x0
                REG_IDT_TABLE5    0x14e4   0xe4e4e4e4   0xe4e4e4e4          0x0
                REG_IDT_TABLE6    0x14e8   0xe4e4e4e4   0xe4e4e4e4          0x0
                REG_IDT_TABLE7    0x14ec   0xe4e4e4e4   0xe4e4e4e4          0x0
                       REG_IMR    0x1604   0x10035d1d   0x12035e1d    0x2000300
      REG_IRQ_MODU_TIMER2_INIT    0x140a     0x640064     0x640064          0x0
       REG_IRQ_MODU_TIMER_INIT    0x1408     0x640064     0x640064          0x0
                       REG_ISR    0x1600    0x5000000    0x8c00000    0xdc00000
                  REG_LOAD_PTR    0x1534          0x0          0x0          0x0
           REG_LTSSM_TEST_MODE    0x12fc       0x6500       0x6500          0x0
                  REG_MAC_CTRL    0x1480    0x4105cef    0x4105cef          0x0
       REG_MAC_HALF_DUPLX_CTRL    0x1498    0x7a1f037    0x7a1f037          0x0
               REG_MAC_IPG_IFG    0x1484   0x60405060   0x60405060          0x0
         REG_MAC_RX_STATUS_BIN    0x1700          0x0          0x0          0x0
         REG_MAC_RX_STATUS_END    0x175c          0x0          0x0          0x0
              REG_MAC_STA_ADDR    0x1488   0x8c5d5ea7   0x8c5d5ea7          0x0
         REG_MAC_TX_STATUS_BIN    0x1760          0x0          0x0          0x0
         REG_MAC_TX_STATUS_END    0x17c0          0x0          0x0          0x0
         REG_MANUAL_TIMER_INIT    0x1404          0x0          0x0          0x0
               REG_MASTER_CTRL    0x1400   0xb0020224   0xb0020224          0x0
             REG_MB_RXF1_RADDR    0x15b4          0x0          0x0          0x0
             REG_MB_RXF2_RADDR    0x15b8          0x0          0x0          0x0
             REG_MB_RXF3_RADDR    0x15bc          0x0          0x0          0x0
           REG_MB_TPD_PROD_IDX    0x15f0          0xf        0x128        0x127
                 REG_MDIO_CTRL    0x1414     0x717c1c     0x1e0ba8     0x6f77b4
                       REG_MTU    0x149c        0x5f2        0x5f2          0x0
             REG_PCIE_CAP_LIST      0x58      0x10010      0x10010          0x0
        REG_PCIE_DEV_MISC_CTRL     0x21c        0xc00        0xc00          0x0
              REG_PCIE_PHYMISC    0x1000   0x78ff2580   0x78ff25a0         0x20
                REG_PHY_STATUS    0x1418    0x7c700dd    0x7c700dd          0x0
               REG_PM_CTRLSTAT      0x44          0x0        0x100        0x100
             REG_RSS_HASH_FLAG    0x1574          0x0          0x0          0x0
            REG_RSS_HASH_VALUE    0x1570          0x0          0x0          0x0
                  REG_RSS_KEY0    0x14b0   0xbeac01fa   0xbeac01fa          0x0
                  REG_RSS_KEY1    0x14b4   0x6a42b73b   0x6a42b73b          0x0
                  REG_RSS_KEY2    0x14b8   0x8030f20c   0x8030f20c          0x0
                  REG_RSS_KEY3    0x14bc   0x77cb2da3   0x77cb2da3          0x0
                  REG_RSS_KEY4    0x14c0   0xae7b30b4   0xae7b30b4          0x0
                  REG_RSS_KEY5    0x14c4   0xd0ca2bcb   0xd0ca2bcb          0x0
                  REG_RSS_KEY6    0x14c8   0x43a38fb0   0x43a38fb0          0x0
                  REG_RSS_KEY7    0x14cc   0x4167253d   0x4167253d          0x0
                  REG_RSS_KEY8    0x14d0   0x255b0ec2   0x255b0ec2          0x0
                  REG_RSS_KEY9    0x14d4   0x6d5a56da   0x6d5a56da          0x0
         REG_RXF0_BASE_ADDR_HI    0x1540          0x0          0x0          0x0
         REG_RXF1_BASE_ADDR_HI    0x1550          0x0          0x0          0x0
         REG_RXF2_BASE_ADDR_HI    0x1554          0x0          0x0          0x0
         REG_RXF3_BASE_ADDR_HI    0x153c          0x0          0x0          0x0
                  REG_RXQ_CTRL    0x15a0   0xc0000080   0xc0001083       0x1003
         REG_RXQ_JMBOSZ_RRDTIM    0x15a4        0x8bf        0x8be          0x1
      REG_RXQ_RXF_PAUSE_THRESH    0x15a8     0xcc0333     0x400310     0x8c0023
             REG_RX_HASH_TABLE    0x1490   0x80100000   0x80028100     0x128100
               REG_SERDES_LOCK    0x1424       0xbb23       0xbb23          0x0
            REG_SMB_STAT_TIMER    0x15c4      0x30d40      0x30d40          0x0
            REG_SRAM_PKTH_ADDR    0x1532    0x40007e0    0x40007e0          0x0
             REG_SRAM_RXF_ADDR    0x1520    0x3ff0000    0x3ff0000          0x0
              REG_SRAM_RXF_LEN    0x1524        0x400        0x400          0x0
            REG_SRAM_TCPH_ADDR    0x1530    0x40007e0    0x40007e0          0x0
             REG_SRAM_TRD_ADDR    0x1518    0x7df07c0    0x7df07c0          0x0
              REG_SRAM_TRD_LEN    0x151c         0x20         0x20          0x0
             REG_SRAM_TXF_ADDR    0x1528    0x7bf0400    0x7bf0400          0x0
              REG_SRAM_TXF_LEN    0x152c        0x3c0        0x3c0          0x0
          REG_TPD_BASE_ADDR_LO    0x154c   0xcf900000   0xcff75010     0x675010
              REG_TPD_CONS_IDX    0x1804          0xf        0x128        0x127
             REG_TPD_RING_SIZE    0x155c         0x80        0x400        0x480
           REG_TRIG_RRD_THRESH    0x15ca      0x10040      0x40010      0x50050
              REG_TRIG_RXTIMER    0x15ce      0x40085      0x40004         0x81
           REG_TRIG_TPD_THRESH    0x15c8      0x10040      0x40010      0x50050
              REG_TRIG_TXTIMER    0x15cc      0x40085      0x40004         0x81
                  REG_TXQ_CTRL    0x1580    0x2000065    0x1000065    0x3000000
               REG_TX_EARLY_TH    0x1584         0xbf         0xbf          0x0
                   REG_VPD_CAP      0x6c          0x3          0x3          0x0
                  REG_VPD_DATA      0x70          0x0          0x0          0x0
                  REG_WOL_CTRL    0x14a0          0x0          0x0          0x0
           REG_WOL_PATTERN_LEN    0x14a4          0x0          0x0          0x0

Thanks,

  Hannes
