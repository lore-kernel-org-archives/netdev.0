From: Jiri Slaby <jirislaby@gmail.com>
Subject: STMMAC: sleep inside atomic
Date: Sat, 04 Sep 2010 13:47:52 +0200
Message-ID: <4C8231E8.5090001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41990 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590Ab0IDLr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 07:47:56 -0400
Received: by fxm13 with SMTP id 13so1757514fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Sep 2010 04:47:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

stanse found that the driver may sleep inside atomic:
stmmac_resume
  -> spin_lock
  -> stmmac_open
    -> request_irq
    -> kzalloc(..., GFP_KERNEL);
    -> init_dma_desc_rings
      -> kmalloc(..., GFP_KERNEL);
    -> and many others...
  -> spin_unlock

Could you fix that?

regards,
-- 
js
