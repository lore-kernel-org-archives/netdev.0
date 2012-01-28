From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 6/7] r8169: missing barriers.
Date: Sat, 28 Jan 2012 13:07:08 +0100
Message-ID: <20120128120708.GA32677@electric-eye.fr.zoreil.com>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com> <20120127205843.GF24507@electric-eye.fr.zoreil.com> <1327741606.7199.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45591 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504Ab2A1MSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 07:18:08 -0500
Content-Disposition: inline
In-Reply-To: <1327741606.7199.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
[...]
> It would be good changelog explains the rationale, or you add comments
> in the code.

Something like :
----------------8<----------------------------------------------------------
rtl8169_tx_interrupt must see the updated queue status from
rtl8169_start_xmit while rtl8169_start_xmit still has to see the
updated dirty index from rtl8169_tx_interrupt.

The window for the TxPoll hack is widened: it should not make much
difference when the last TxPoll request in a close serie of xmit fails as
long as the Tx napi method runs late enough after the last successful xmit.
------------------------------------------>8--------------------------------

Your comments are welcome.

-- 
Ueimor
