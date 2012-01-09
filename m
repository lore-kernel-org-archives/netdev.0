From: phil.edworthy@renesas.com
Subject: Re: Bug in smsc911x_init
Date: Mon, 09 Jan 2012 17:23:03 +0000
Message-ID: <OF4F6A417C.1FA0400B-ON80257980.005F2B6D-80257980.005F7EB5@eu.necel.com>
References: <OF308AD908.27774DC2-ON80257980.0046416E-80257980.004A4357@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Linus Walleij <linus.walleij@linaro.org>,
	Robert Marklund <robert.marklund@stericsson.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor1.renesas.com ([210.160.252.171]:61800 "EHLO
	relmlor1.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932266Ab2AIRXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 12:23:20 -0500
Received: from relmlir1.idc.renesas.com ([10.200.68.151])
 by relmlor1.idc.renesas.com ( SJSMS)
 with ESMTP id <0LXJ008RFKAVTH30@relmlor1.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 10 Jan 2012 02:23:19 +0900 (JST)
Received: from relmlac3.idc.renesas.com ([10.200.69.23])
 by relmlir1.idc.renesas.com (SJSMS)
 with ESMTP id <0LXJ00LNYKAV6EE0@relmlir1.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 10 Jan 2012 02:23:19 +0900 (JST)
In-reply-to: <OF308AD908.27774DC2-ON80257980.0046416E-80257980.004A4357@LocalDomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

> I've found that commit 3ac3546e5f17248d961ef0f4a27e75564bf71578, 
"net/smsc911x: Always wait for the chip to be ready" can cause init to 
fail. I am working on an out of tree board, but it will affect other 
users. With an smsc 9218 connected to a big endian processor using a 
16-bit bus, we have to wait for the value read from PMT_CTRL to be 0x10000 
rather than 0x1.
> 
> However, I am not sure what the correct test should be, as the data 
sheet states that you can't read or write to any other reg until the 
PMT_CTRL READY bit is set. Maybe we can poll until we get a valid result 
from reading BYTE_TEST, and then wait for the PMT_CTRL (endian specific) 
READY bit?

Whoops... please ignore. The problem was one of platform config data. For 
some reason this was set to SMSC911X_USE_32BIT, and somehow everything 
else except this new code in init works just fine.

Sorry about that,
Phil
