From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: Is this 32-bit NCM?
Date: Sun, 30 Nov 2014 19:36:14 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1411301931280.2605@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <87ppc957h1.fsf@nemi.mork.no> <alpine.LNX.2.03.1411271037050.9464@gmail.com> <874mtl55ar.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-992934442-1417372353=:2605"
Cc: Eli Britstein <Eli.Britstein@audiocodes.com>, youtux@gmail.com,
	alexxst@gmail.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org,
	Midge Shaojun Tan <ShaojunMidge.Tan@audiocodes.com>,
	Kevin Zhu <Mingying.Zhu@audiocodes.com>
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:45446 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332AbaK3SgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 13:36:01 -0500
In-Reply-To: <874mtl55ar.fsf@nemi.mork.no>
Content-ID: <alpine.LNX.2.03.1411301932550.2633@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-992934442-1417372353=:2605
Content-Type: TEXT/PLAIN; CHARSET=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.LNX.2.03.1411301932551.2633@gmail.com>

Thank you Bjorn for the help and suggestions.
These are parameters that the driver ends up choosing:
/sys/class/net/wwan0/cdc_ncm/bmNtbFormatsSupported:0x0003
/sys/class/net/wwan0/cdc_ncm/dwNtbInMaxSize:131072
/sys/class/net/wwan0/cdc_ncm/dwNtbOutMaxSize:16384
/sys/class/net/wwan0/cdc_ncm/min_tx_pkt:14848
/sys/class/net/wwan0/cdc_ncm/rx_max:16384
/sys/class/net/wwan0/cdc_ncm/tx_max:16384
/sys/class/net/wwan0/cdc_ncm/tx_timer_usecs:400
/sys/class/net/wwan0/cdc_ncm/wNdpInAlignment:4
/sys/class/net/wwan0/cdc_ncm/wNdpInDivisor:4
/sys/class/net/wwan0/cdc_ncm/wNdpInPayloadRemainder:2
/sys/class/net/wwan0/cdc_ncm/wNdpOutAlignment:4
/sys/class/net/wwan0/cdc_ncm/wNdpOutDivisor:4
/sys/class/net/wwan0/cdc_ncm/wNdpOutPayloadRemainder:2
/sys/class/net/wwan0/cdc_ncm/wNtbOutMaxDatagrams:0

Sorry if I did not report them before. If I missed someone in CC please add it 
guys.
Kevin - after you discovered that the device might handle the offset in a 
different way, have you tried this approach?


On Thu, 27 Nov 2014, Bjørn Mork wrote:

==Date: Thu, 27 Nov 2014 11:03:24
==From: Bjørn Mork <bjorn@mork.no>
==To: Enrico Mioso <mrkiko.rs@gmail.com>
==Cc: youtux@gmail.com, alexxst@gmail.com, linux-usb@vger.kernel.org,
==    netdev@vger.kernel.org
==Subject: Re: Is this 32-bit NCM?
==
==Enrico Mioso <mrkiko.rs@gmail.com> writes:
==
==> Ok - we can arrive to some ocnclusions regarding the E3272.
==> First of all - the modem seems buggy enough to not be able to handle requests 
==> for different formats. You need to unplug and re-plug it, but this is onlyan 
==> impression and is reasonable.
==>
==> Then - the modem will accept to ndisdup the connection with
==> at^ndisdup=1,1,"internet"
==> but - if we use huawei_cdc_ncm + cdc_ncm we have no flow handling messages and 
==> the modem stops here.
==> If we use the cdc_ncm 32-bit driver (modified) we get lotfs of
==> ^dsflorpt
==> that's how it should be.
==> So I think we can say that something is changing.
==> Then there's the alignment problem you mentioned in your previous reply. And 
==> this is hard to solve.
==> could you try to help me understand where the problem is?
==> I feel like we are very close to the solution but something isn't working.
==> Or might be just try to change the 16 bit driver?
==
==If you use a recent version of the driver as a basis, then you get the
==CDC NCM NTB parameters in sysfs (if not, then you need to enable
==debugging and look in the log for these values).  For example:
==
==bjorn@nemi:~$ grep . /sys/class/net/wwan0/cdc_ncm/*
==/sys/class/net/wwan0/cdc_ncm/bmNtbFormatsSupported:0x0001
==/sys/class/net/wwan0/cdc_ncm/dwNtbInMaxSize:15360
==/sys/class/net/wwan0/cdc_ncm/dwNtbOutMaxSize:15360
==/sys/class/net/wwan0/cdc_ncm/min_tx_pkt:13824
==/sys/class/net/wwan0/cdc_ncm/rx_max:15360
==/sys/class/net/wwan0/cdc_ncm/tx_max:15360
==/sys/class/net/wwan0/cdc_ncm/tx_timer_usecs:400
==/sys/class/net/wwan0/cdc_ncm/wNdpInAlignment:4
==/sys/class/net/wwan0/cdc_ncm/wNdpInDivisor:1
==/sys/class/net/wwan0/cdc_ncm/wNdpInPayloadRemainder:0
==/sys/class/net/wwan0/cdc_ncm/wNdpOutAlignment:4
==/sys/class/net/wwan0/cdc_ncm/wNdpOutDivisor:32
==/sys/class/net/wwan0/cdc_ncm/wNdpOutPayloadRemainder:0
==/sys/class/net/wwan0/cdc_ncm/wNtbOutMaxDatagrams:32
==
==
==The possible problem I am thinking of is proper handling of the
==wNdp*PayloadRemainder values. See section 3.3.4 "NCM Ethernet Frame
==Alignment" in the spec.  Which is confusing as hell, but if I understand
==it correctly then we are supposed to align the start of the IP packets
==(the "payload", _not_ the ethernet frame) to a whole wNdp*Divisor number
==as long as the wNdp*PayloadRemainder is 0.
==
==
==Bjørn
==
--8323328-992934442-1417372353=:2605--
