From: Karsten Wiese <fzu@wemgehoertderstaat.de>
Subject: Re: [PATCH] Disable polling in rtl8169_suspend() to prevent race with rtl8169_interrupt()
Date: Wed, 17 Oct 2007 00:10:36 +0200
Message-ID: <200710170010.36329.fzu@wemgehoertderstaat.de>
References: <200710161846.52509.fzu@wemgehoertderstaat.de> <200710162127.52228.fzu@wemgehoertderstaat.de> <20071016210412.GB8049@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout2.freenet.de ([195.4.92.92]:41411 "EHLO mout2.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965907AbXJPWKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 18:10:40 -0400
In-Reply-To: <20071016210412.GB8049@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 16. Oktober 2007 schrieb Francois Romieu:
> Karsten Wiese <fzu@wemgehoertderstaat.de> :
> [...]
> > Forgot to say: patch is against 2.6.23. Stable material, if it gets an ACK.
> > The BUG happens since months here, if not since I hibernate this pc.
> 
> Can you give the patch below a try too ?

I don't know how to reliably make the bug happen, it occured once a week
"normally". Before I try please look through this stuff:

with an unpatched r8169 after bug happened today morning i gathered some
diagnostics:
  [root@a64 ~]# ethtool eth0
  Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Full
	Port: Twisted Pair
this          ^..........^ looked funny to me 
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Supports Wake-on: pumbg
	Wake-on: g
	Current message level: 0x00000033 (51)
	Link detected: no
unexpected too         ^^

then i did:
  [root@a64 ~]# ethtool -s eth0 port mii
  [root@a64 ~]# ethtool eth0
  Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: Twisted Pair
back to normal ^.........^
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: pumbg
        Wake-on: g
        Current message level: 0x00000033 (51)
        Link detected: yes
expected value here too^.^ and eth0 worked again.

Can your patch cause the same effect as the "ethtool -s eth0 port mii" in
the bug case?

Do you agree that rtl8169_interrupt() should not be called after
rtl8169_asic_down() when in rtl8169_suspend() and before rtl8169_resume()?
If yes, how should that be achieved?

      Karsten
