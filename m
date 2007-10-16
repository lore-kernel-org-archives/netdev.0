From: Karsten Wiese <fzu@wemgehoertderstaat.de>
Subject: Re: [PATCH] Disable polling in rtl8169_suspend() to prevent race with rtl8169_interrupt()
Date: Tue, 16 Oct 2007 21:27:51 +0200
Message-ID: <200710162127.52228.fzu@wemgehoertderstaat.de>
References: <200710161846.52509.fzu@wemgehoertderstaat.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout2.freenet.de ([195.4.92.92]:40074 "EHLO mout2.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761242AbXJPT15 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 15:27:57 -0400
In-Reply-To: <200710161846.52509.fzu@wemgehoertderstaat.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 16. Oktober 2007 schrieb Karsten Wiese:
> Hi,
> 
> Sometimes (~ 1 in 10) after suspend to disk my r8169 nic doesn't work and a
> "r8169: eth0: link down" gets mingled up with those suspend messages.
> First tests show nothing bad, so maybe this patch really helps.
> Will post again, if it doesn't.
> 
>       Karsten
> ------------------>
> 
> Disable polling in rtl8169_suspend() to prevent race with rtl8169_interrupt()
> 
> rtl8169_interrupt() is called during polling.
> Without patch, rtl8169_interrupt() could run after rtl8169_asic_down(),
> causing a disabled link state being saved later in rtl8169_suspend() by
> pci_save_state().
> netif_stop_queue() can go as it is called by netif_device_detach().
> 
> Signed-off-by: Karsten Wiese <fzu@wemgehoertderstaat.de>

Forgot to say: patch is against 2.6.23. Stable material, if it gets an ACK.
The BUG happens since months here, if not since I hibernate this pc.

git HEAD would need a similar fix I think, haven't tried yet.

      Karsten
