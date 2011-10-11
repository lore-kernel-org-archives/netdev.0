From: David Lamparter <equinox@diac24.net>
Subject: Re: e100 + VLANs?
Date: Tue, 11 Oct 2011 17:29:18 +0200
Message-ID: <20111011152917.GE2840382@jupiter.n2.diac24.net>
References: <20111010101954.GB2840382@jupiter.n2.diac24.net>
 <4E9307CB.4050704@msgid.tls.msk.ru>
 <1318259152.3227.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111010151343.GB3260852@jupiter.n2.diac24.net>
 <4E932278.8010802@tls.msk.ru>
 <4E941198.9000307@msgid.tls.msk.ru>
 <CAL4WiiphpyizVaNkvOdJp1+UK53TkGw9RXnC-vzH7fTNpBAAEA@mail.gmail.com>
 <4E942F8A.90205@msgid.tls.msk.ru>
 <1318334674.2538.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <4E943CF7.6030905@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Lamparter <equinox@diac24.net>,
	jeffrey.t.kirsher@intel.com, netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:45142 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699Ab1JKP3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 11:29:42 -0400
Content-Disposition: inline
In-Reply-To: <4E943CF7.6030905@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 11, 2011 at 04:56:23PM +0400, Michael Tokarev wrote:
> So it looks like the card merely ignores these packets.
> 
> So little result for so much efforts... :(
> 
> But it is not really that bad I think - it is an obsolete hardware.

The knowledge and code for this is actually around line 1142 of e100.c:
        if (nic->mac >= mac_82558_D101_A4) {
                config->fc_disable = 0x1;       /* 1=Tx fc off, 0=Tx fc on */
                config->mwi_enable = 0x1;       /* 1=enable, 0=disable */
                config->standard_tcb = 0x0;     /* 1=standard, 0=extended */
                config->rx_long_ok = 0x1;       /* 1=VLANs ok, 0=standard */

where rx_long_ok is the configuration bit to enable frame reception
for >1514 byte frames. I guess your card is < mac_82558_D101_A4...

(cf. "Intel 8255x 10/100 Mbps Ethernet Controller Family Open Source
Software Developer Manual" page 78/86 - "Long Receive OK. This bit is
reserved on the 82557 and should be set to 0. When this bit is set on
the 82558 or 82559, the device considers received frames that have
a data field longer than 1500 bytes as good frames.")


-David
