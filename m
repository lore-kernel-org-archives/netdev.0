From: "Chris Friesen" <cfriesen@nortel.com>
Subject: sun neptune mis-detecting ethernet crc faults?
Date: Mon, 29 Jun 2009 14:57:05 -0600
Message-ID: <4A492AA1.2020204@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:53465 "EHLO
	zcars04e.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210AbZF2U5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 16:57:08 -0400
Received: from zcarhxs1.corp.nortel.com (zcarhxs1.corp.nortel.com [47.129.230.89])
	by zcars04e.nortel.com (Switch-2.2.0/Switch-2.2.0) with ESMTP id n5TKtd813740
	for <netdev@vger.kernel.org>; Mon, 29 Jun 2009 20:55:39 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

David Miller is busy and suggested someone on the list might be able to
help.

We have some boards using the Sun Neptune ethernet adapters.  We're
seeing behaviour that at this point looks like a hardware glitch
in the ethernet CRC validation on the receive path.  It appears to be
incorrectly detecting a corrupt CRC and dropping the frames.  (We've
enabled port mirroring on the switch and the frames are received without
errors on the eavesdropper board.)

The odd thing is that we're using a TCP connection and once the CRC
glitch shows up for a particular chunk of data it continues to drop all
the retransmissions for that chunk as having bad CRCs, even though their
CRC values are totally different due to different embedded timestamps.

Has anyone heard of anything like this on the Neptune hardware?  MTU is
set to 2000 if it matters, though we're planning on retesting with it
set to 1500.

I'm considering disabling the hardware CRC check as a
verification--looking at the niu driver I think I should be able to do
this by not including XMAC_CONFIG_RX_CRC_CHK_DIS in the big list of
flags being OR'd in niu_init_rx_xmac().

Anyone have any suggestions?

Thanks,

Chris
