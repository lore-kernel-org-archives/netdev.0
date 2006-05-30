From: Andrew Morton <akpm@osdl.org>
Subject: llc use-after-free
Date: Tue, 30 May 2006 15:41:48 -0700
Message-ID: <20060530154148.ed982f6b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:23482 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964791AbWE3Whj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 18:37:39 -0400
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


My test box running rc5-mm1 was kinda sitting there doing nothing when it
decided to have an oops in the llc code.  See

http://www.zip.com.au/~akpm/linux/patches/stuff/dsc03542.jpg

gdb says:



0x197 is in llc_rcv (net/llc/llc_input.c:68).
63      static __inline__ int llc_pdu_type(struct sk_buff *skb)
64      {
65              int type = LLC_DEST_CONN; /* I-PDU or S-PDU type */
66              struct llc_pdu_sn *pdu = llc_pdu_sn_hdr(skb);
67      
68              if ((pdu->ctrl_1 & LLC_PDU_TYPE_MASK) != LLC_PDU_TYPE_U)
69                      goto out;
70              switch (LLC_U_PDU_CMD(pdu)) {
71              case LLC_1_PDU_CMD_XID:
72              case LLC_1_PDU_CMD_UI:
