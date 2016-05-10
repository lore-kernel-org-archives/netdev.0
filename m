From: Vivek Bhagat <vivek.bhagat89@gmail.com>
Subject: ax88179_178a: disabled FLAG_MULTI_PACKET
Date: Tue, 10 May 2016 13:05:28 +0530
Message-ID: <CA+vmRF7Rb9HqCjCW84YEqofBDTcsst89BU=zX=Y5fMCeXbP+KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:35647 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbcEJHf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 03:35:29 -0400
Received: by mail-qg0-f49.google.com with SMTP id f74so1992053qge.2
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 00:35:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

ax88179_178a_rx_fixup() function is cloning the data and calling
usbnet_skb_return(). Since FLAG_MULTI_PACKET is not set,
usbnet_skb_return() is being called second time within rx_process()
function in usbnet.c.

I simply enabled the flag in ax88179_info as below -
    .flags = FLAG_ETHER..| FLAG_MULTI_PACKET

Ping stops working.

Could anyone please point out what could be the reason behind sending
same packets 2 times to upper layer (from usbnet and its class driver
ax88179_178a)?

In case of asix 2.0 driver, avove flag is set and it is working.


Thanks,
Vivek
