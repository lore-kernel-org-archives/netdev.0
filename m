From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: move padding in struct skb_shared_info
Date: Mon, 10 Apr 2017 11:07:56 +0300
Message-ID: <20170410080755.GA24514@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, edumazet@google.com,
        netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34678 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750989AbdDJIIA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 04:08:00 -0400
Received: by mail-lf0-f67.google.com with SMTP id x72so3254067lfb.1
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 01:08:00 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 7f564528a480084e2318cd48caba7aef4a54a77f
("skbuff: Extend gso_type to unsigned int.") created padding as first
field of struct skb_shared_info requiring [R64+imm8] addressing mode
for all fields.

Patch bubbles up padding brinding code size down to original levels and
even smaller:

	add/remove: 0/0 grow/shrink: 4/304 up/down: 20/-720 (-700)
	function                                     old     new   delta
	iwl_trans_pcie_tx                           3994    4006     +12
	tap_do_read                                 1070    1074      +4
	packet_recvmsg                              1155    1157      +2
	be_xmit                                     2038    2040      +2
	zerocopy_sg_from_iter                        455     454      -1
		...
	__ef4_rx_packet                             1358    1349      -9
	hix5hd2_poll                                1787    1777     -10
	e1000_clean_jumbo_rx_irq                    3599    3587     -12
	skb_try_coalesce                            1118    1105     -13
	xenvif_tx_build_gops                        5057    5043     -14

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/skbuff.h |    1 -
 1 file changed, 1 deletion(-)

--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -413,7 +413,6 @@ struct ubuf_info {
  * the end of the header data, ie. at skb->end.
  */
 struct skb_shared_info {
-	unsigned short	_unused;
 	unsigned char	nr_frags;
 	__u8		tx_flags;
 	unsigned short	gso_size;
