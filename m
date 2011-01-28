From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: use RxFIFO overflow workaround for 8168c chipset
Date: Fri, 28 Jan 2011 18:28:55 +0100
Message-ID: <20110128172854.GA8151@electric-eye.fr.zoreil.com>
References: <1296127451-12640-1-git-send-email-ivecera@redhat.com> <20110127143219.GA7831@electric-eye.fr.zoreil.com> <1296156217.8720.3.camel@ceranb.brq.redhat.com> <20110128172537.GA11064@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes <hayeswang@realtek.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54880 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312Ab1A1Ra7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 12:30:59 -0500
Content-Disposition: inline
In-Reply-To: <20110128172537.GA11064@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Vecera <ivecera@redhat.com> :
[...]
> The test case was: Migration of the several kvm guests at the same time
> between two hosts.

:o(

Could you check if simply leaving the irq handler when status == RxFIFOOver
works by any chance ?

Faced with pktgen, RTL_GIGA_MAC_VER_26 spits RxFIFO overflow errors quite
fast (10000 packets kill it, reliably). The same fix as your avoids the crash.

As is, RTL_GIGA_MAC_VER_12 seems to survive at 900kpps. It signals RXFIFO
overflow, loses half the packets and sends pause control frames but it does
not crash. I have made it leave the irq handler when status == RxFIFOOver.
I'll see if it can stand a few hours like that.

-- 
Ueimor
