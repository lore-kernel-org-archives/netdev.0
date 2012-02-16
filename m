From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Bogus frames transmitted with r8169 & fragmentation & large mtu
Date: Thu, 16 Feb 2012 13:04:48 +0100
Message-ID: <20120216120448.GB9504@electric-eye.fr.zoreil.com>
References: <20120215163748.GA3998@elliptictech.com> <1329333239.2469.3.camel@edumazet-laptop> <20120215232303.GB31463@electric-eye.fr.zoreil.com> <33249D172FBD4AE09E24D4F24E973BD9@realtek.com.tw> <20120216074637.GA6208@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Eric Dumazet'" <eric.dumazet@gmail.com>,
	"'Nick Bowler'" <nbowler@elliptictech.com>, netdev@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41506 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994Ab2BPMRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 07:17:16 -0500
Content-Disposition: inline
In-Reply-To: <20120216074637.GA6208@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> I am testing it now.

It does not fix the problem. It seems to make a difference but I still
see a few percents packet loss. The pattern has changed a bit too: there
are more bogus IP fragment offsets.

Trying with 'ping -qf -c 100 -l 2 -s 65507 10.0.7.1'

Good:

239   0.020107     10.0.7.1 -> 10.0.7.5     IP Fragmented IP protocol (proto=ICMP 0x01, off=0, ID=9f97)
240   0.020116     10.0.7.1 -> 10.0.7.5     IP Fragmented IP protocol (proto=ICMP 0x01, off=8976, ID=9f97)
241   0.020122     10.0.7.1 -> 10.0.7.5     IP Fragmented IP protocol (proto=ICMP 0x01, off=17952, ID=9f97)
242   0.020128     10.0.7.1 -> 10.0.7.5     IP Fragmented IP protocol (proto=ICMP 0x01, off=26928, ID=9f97)
243   0.020134     10.0.7.1 -> 10.0.7.5     IP Fragmented IP protocol (proto=ICMP 0x01, off=35904, ID=9f97)
244   0.020139     10.0.7.1 -> 10.0.7.5     IP Fragmented IP protocol (proto=ICMP 0x01, off=44880, ID=9f97)
245   0.020145     10.0.7.1 -> 10.0.7.5     IP Fragmented IP protocol (proto=ICMP 0x01, off=53856, ID=9f97)
246   0.020150     10.0.7.1 -> 10.0.7.5     ICMP Echo (ping) reply    (id=0x04c7, seq(be/le)=16/4096, ttl=64)

Bad:

247   0.020809     10.0.7.5 -> 10.0.7.1     IP Fragmented IP protocol (proto=ICMP 0x01, off=0, ID=dce9)
248   0.020977     10.0.7.5 -> 10.0.7.1     IP Fragmented IP protocol (proto=ICMP 0x01, off=8976, ID=dce9)
249   0.021046     10.0.7.5 -> 10.0.7.1     IP Fragmented IP protocol (proto=ICMP 0x01, off=17952, ID=dce9)
250   0.021192     10.0.7.5 -> 10.0.7.1     IP Fragmented IP protocol (proto=ICMP 0x01, off=26928, ID=dce9)
251   0.021199     10.0.7.5 -> 10.0.7.1     IP Fragmented IP protocol (proto=ICMP 0x01, off=35904, ID=dce9)
252   0.021291     10.0.7.5 -> 10.0.7.1     IP Fragmented IP protocol (proto=ICMP 0x01, off=44880, ID=dce9)
253   0.021298     10.0.7.5 -> 10.0.7.1     IP Fragmented IP protocol (proto=ICMP 0x01, off=62832, ID=dce9)

So far I have only seen it with the 2nd and last fragment.

-- 
Ueimor
