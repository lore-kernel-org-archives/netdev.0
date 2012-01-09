From: phil.edworthy@renesas.com
Subject: Bug in smsc911x_init
Date: Mon, 09 Jan 2012 13:31:09 +0000
Message-ID: <OF308AD908.27774DC2-ON80257980.0046416E-80257980.004A4357@eu.necel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Robert Marklund <robert.marklund@stericsson.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor1.renesas.com ([210.160.252.171]:50873 "EHLO
	relmlor1.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755024Ab2AINb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 08:31:27 -0500
Received: from relmlir1.idc.renesas.com ([10.200.68.151])
 by relmlor1.idc.renesas.com ( SJSMS)
 with ESMTP id <0LXJ008OY9KETH00@relmlor1.idc.renesas.com> for
 netdev@vger.kernel.org; Mon, 09 Jan 2012 22:31:26 +0900 (JST)
Received: from relmlac2.idc.renesas.com ([10.200.69.22])
 by relmlir1.idc.renesas.com (SJSMS)
 with ESMTP id <0LXJ00LJO9KE6E00@relmlir1.idc.renesas.com> for
 netdev@vger.kernel.org; Mon, 09 Jan 2012 22:31:26 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've found that commit 3ac3546e5f17248d961ef0f4a27e75564bf71578, 
"net/smsc911x: Always wait for the chip to be ready" can cause init to 
fail. I am working on an out of tree board, but it will affect other 
users. With an smsc 9218 connected to a big endian processor using a 
16-bit bus, we have to wait for the value read from PMT_CTRL to be 0x10000 
rather than 0x1.

However, I am not sure what the correct test should be, as the data sheet 
states that you can't read or write to any other reg until the PMT_CTRL 
READY bit is set. Maybe we can poll until we get a valid result from 
reading BYTE_TEST, and then wait for the PMT_CTRL (endian specific) READY 
bit?

Regards
Phil
