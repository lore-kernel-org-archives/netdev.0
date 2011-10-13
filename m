From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: e100 + VLANs?
Date: Thu, 13 Oct 2011 13:22:27 +0400
Message-ID: <4E96ADD3.90100@msgid.tls.msk.ru>
References: <20111010101954.GB2840382@jupiter.n2.diac24.net> <4E9307CB.4050704@msgid.tls.msk.ru> <1318259152.3227.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111010151343.GB3260852@jupiter.n2.diac24.net> <4E932278.8010802@tls.msk.ru> <4E941198.9000307@msgid.tls.msk.ru> <CAL4WiiphpyizVaNkvOdJp1+UK53TkGw9RXnC-vzH7fTNpBAAEA@mail.gmail.com> <4E942F8A.90205@msgid.tls.msk.ru> <1318334674.2538.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4E943CF7.6030905@msgid.tls.msk.ru> <20111011152917.GE2840382@jupiter.n2.diac24.net> <20111011163855.0000646f@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Lamparter <equinox@diac24.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:57906 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753714Ab1JMJWa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Oct 2011 05:22:30 -0400
In-Reply-To: <20111011163855.0000646f@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.10.2011 03:38, Jesse Brandeburg wrote:
[..]
>> The knowledge and code for this is actually around line 1142 of e100.c:
>>         if (nic->mac >= mac_82558_D101_A4) {
>>                 config->fc_disable = 0x1;       /* 1=Tx fc off, 0=Tx fc on */
>>                 config->mwi_enable = 0x1;       /* 1=enable, 0=disable */
>>                 config->standard_tcb = 0x0;     /* 1=standard, 0=extended */
>>                 config->rx_long_ok = 0x1;       /* 1=VLANs ok, 0=standard */
>>
>> where rx_long_ok is the configuration bit to enable frame reception
>> for >1514 byte frames. I guess your card is < mac_82558_D101_A4...
>>
>> (cf. "Intel 8255x 10/100 Mbps Ethernet Controller Family Open Source
>> Software Developer Manual" page 78/86 - "Long Receive OK. This bit is
>> reserved on the 82557 and should be set to 0. When this bit is set on
>> the 82558 or 82559, the device considers received frames that have
>> a data field longer than 1500 bytes as good frames.")
> 
> David, thank you for posting that, while you were typing I was
> researching the same thing, so FWIW, I concur with your conclusion.
> 
> ouch, OP your hardware is really really old:
>> 00:12.0 Ethernet controller: Intel Corporation 82557/8/9/0/1 Ethernet Pro 100 (rev 02)
>> Subsystem: Intel Corporation EtherExpress PRO/100B (TX)
> 
> rev 2 is D100_C, which is 82557.
> 
> the hardware is NOT capable of long receives (i.e. vlan packets).
> If it was then they should generally fit in the receive buffer and be
> handled and not discarded.

Can this knowlege be added to the driver somehow, so that others
will not hit the same trap as I did? :)  _If_ there's any value
in that (I guess there aren't many users with that hardware left),
and if that's easy to do ofcourse... ;)

Thanks!

/mjt
