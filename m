From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: smsc75xx & smsc95xx, setting skb->truesize correctly?
Date: Mon, 20 Aug 2012 17:57:06 +0300
Message-ID: <20120820175706.12394vktsvm3yvqc@www.81.fi>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-mail-sa-02.sanoma.fi ([158.127.18.162]:48640 "EHLO
	sd-mail-sa-02.sanoma.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308Ab2HTO5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 10:57:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Is setting skb->truesize in smsc75xx and smsc95xx correct?
In smsc75xx/smsc95xx_rx_fixup(), input skb containing multiple packets  
is cloned and truesize for each clone is set to packet-size +  
sizeof(struct sk_buff), but input skb has minimum allocation size of  
9000 bytes (MAX_SINGLE_PACKET_SIZE) and maximum of 18944 bytes  
(DEFAULT_HS_BURST_CAP_SIZE) (+ NET_IP_ALIGN). Doesn't this cause  
truesize to be underestimated?

-Jussi
