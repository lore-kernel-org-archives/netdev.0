From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 in 2.6.18 silently corrupting data, 2.6.22-rc3 link not detected at all
Date: Mon, 28 May 2007 21:54:22 +0200
Message-ID: <20070528195422.GA4927@electric-eye.fr.zoreil.com>
References: <76366b180705281110j472671a1h6ff5ed5fa711c45e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrew Paprocki <andrew@ishiboo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:57531 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751645AbXE1Tzu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 15:55:50 -0400
Content-Disposition: inline
In-Reply-To: <76366b180705281110j472671a1h6ff5ed5fa711c45e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Paprocki <andrew@ishiboo.com> :
[...]
> This struck me as strange, so I checked and it is directly connected
> to the MAC addr of the ethernet card: 00:0c:76:ae:b5:16
> 
> I figured that a newer kernel might fix this issue, so I built
> 2.6.22-rc3 and under that kernel the r8169 device doesn't work at all.
> It never detects a valid link. I insmod'd the driver with debug=16 and
> all I see it printing is "eth0: PHY reset until link up" on a timer.

Ok.

You will not pollute the console much with a single bit of debug.

> I see some patches flying around for r8169.c, but I'm not sure if
> either of these two cases are known/fixed

I am not sure either. With the usual luck, I could bet that an update
will make the alignment issue go away while introducing a link negotiation
regression.

> Also, this is a gigabit NIC on a gig-e switched network, yet mii-tool
> only reports 10mb-hd speed... ?

Auto-negotiation probably failed. Your ethernet cables are fine, aren't they ?

Please:
- send a 'lspci -vvx' of the host
- try 2.6.22-rc3 +
  http://www.fr.zoreil.com/people/francois/misc/20070527-2.6.22-rc3-r8169.patch
- send a complete dmesg (2.6.18 and 2.6.22-rc3 patched)
- send 'mii-tool -vv' and 'ethtool -S' for a patched 2.6.22-rc3
- send .config (one never knows...)

[...]
> # ethtool -S eth0
> NIC statistics:
>     tx_packets: 4397
>     rx_packets: 6701
>     tx_errors: 1
>     rx_errors: 999
>     rx_missed: 0
>     align_errors: 25770
                    ^^^^^
~2/3 of misaligned packets. Wow. Same thing with both interfaces ?

If the patched kernel does not detect the link, restart autonegotiation
with mii-tool.

-- 
Ueimor
