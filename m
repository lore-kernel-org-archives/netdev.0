From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: new SiS gige driver
Date: Mon, 11 Aug 2003 21:22:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102229342@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Time to give something back:

* sis190_pci_driver.remove should be __devexit_p()
* suspend/resume important in today's world?
* SiS190_get_stats is defined static but declared non-static.
  A little rearranging would eliminate the need for forward
  declarations, thus avoiding this issue.
* // comments
* Missing KERN_XXX on some printk's.
* err_out does unregister_netdev() in _init_board before
register_netdev().
* In _remove_one, no pci_disable_device().
* _open: cleanup on RxBufferRings failure is missing - no error
  return or cleanup.
* _hw_start: pretty scary magic numbers.
* Comment on sis190_private.curr_tx says "Rx".
* Modulo operator on ring indexes is expensive on some archs.
* _start_xmit: setting PSize can just use skb->len since already
skb_padto.
* MODULE_PARAM(media) isn't used.  Then goes MAX_UNITS.
* no big-endian support.
* no NETIF_MSG_xxx or msg_enable suppport.
* Add class net ethernet restiction to sis190_pci_tbl[].
* Use PCI_VENDOR_ID_SI for 0x1039 in sis190_pci_tbl[].
* Use ETH_ALEN for MAC_ADDR_LEN.
* MAX_ETH_FRAME_SIZE isn't used.
* TX_FIFO_THRESH and TX_DMA_BURST aren't used.
* EarlyTxThld, RxPacketMaxSize, InterFrameGap aren't used.
* not sure why there is a cast on SiS_R32(reg) using (unsigned long)?
* [Ouch!] Is that a skb_copy_and_sum in the Rx path?  That's going
  to hurt performance.  Looks like RxDescArray[].buf_addr could
  point to a pci_map_single(skb).
* Alternatively, in _rx_interurpt, why keep setting
RxDescArray.buf_addr?
  Maybe h/w erases the previous value?
* _interrupt: handled is never set to 1.
* ____cacheline_aligned sis190_private.

-scott
