From: Tom Herbert <tom@herbertland.com>
Subject: Re: Extreme slowness in IPIP tunnel when routing through kernel 3.18
 and later
Date: Thu, 17 Mar 2016 09:47:23 -0700
Message-ID: <CALx6S34YOS=q2-sjK8ZkkRWZ152Y8SBWEP=oxJNM8HTQ-1MhRw@mail.gmail.com>
References: <56EAB8F3.7060802@ednet.ns.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Patrick Boutilier <boutilpj@ednet.ns.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:35624 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933857AbcCQQrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 12:47:25 -0400
Received: by mail-ig0-f170.google.com with SMTP id vf5so1171130igb.0
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 09:47:24 -0700 (PDT)
In-Reply-To: <56EAB8F3.7060802@ednet.ns.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2016 at 7:02 AM, Patrick Boutilier <boutilpj@ednet.ns.ca> wrote:
> I have an IPIP tunnel setup between two hosts in different buildings. The
> Linux router they route through causes extreme slowness in the tunnel when
> running kernels from 3.18 on . tcpdump shows many cksum errors which don't
> show up in the 3.17 and earlier kernels. Speed goes back to normal when
> rx-checksumming and tx-checksumming are turned off using ethtool on the
> Linux router . Would this be an effect of bulk network packet transmission
> that was introduced in 3.18 or some other issue?
>
If this is happening on a router then the only case where checksums
are pertinent should be if GSO/GRO is enabled. Please try disabling
these. Also, are these showing up as checksum errors on the receiver
(netstat -s).


>
> eth2
> driver: igb
> version: 5.2.15-k
> firmware-version: 1.5.1
> bus-info: 0000:06:00.0
> supports-statistics: yes
> supports-test: yes
> supports-eeprom-access: yes
> supports-register-dump: yes
> supports-priv-flags: no
>
>
> eth6
> driver: ixgbe
> version: 3.19.1-k
> firmware-version: 0x80000389
> bus-info: 0000:41:00.0
> supports-statistics: yes
> supports-test: yes
> supports-eeprom-access: yes
> supports-register-dump: yes
> supports-priv-flags: no
>
>
>
>
>
> Example of cksum from tcpdump:
>
> Flags [.], cksum 0x2237 (incorrect -> 0xbb02), seq 424119200:424120648, ack
> 1, win 115, options [nop,nop,TS val 303173784 ecr 3971495454], length 1448
>
>
>
>
>
> Results of nuttcp test with rx-checksumming and tx-checksumming on:
>
>
> Testing upload inside tunnel
>
>
>
>     0.0625 MB /   5.00 sec =    0.1048 Mbps    79 retrans
>     0.0625 MB /   5.00 sec =    0.1048 Mbps    59 retrans
>     0.0625 MB /   5.00 sec =    0.1049 Mbps    27 retrans
>
>     0.2096 MB /  16.11 sec =    0.1092 Mbps 0 %TX 0 %RX 186 retrans 0.47
> msRTT
>
>
>
> Testing download inside tunnel
>
>
>
>     0.5000 MB /   5.00 sec =    0.8389 Mbps   112 retrans
>     2.6250 MB /   5.00 sec =    4.4040 Mbps   412 retrans
>     0.8750 MB /   5.00 sec =    1.4680 Mbps   156 retrans
>
>     4.0243 MB /  15.48 sec =    2.1809 Mbps 0 %TX 0 %RX 705 retrans 0.47
> msRTT
>
>
> Testing upload outside tunnel
>
>
>
>   423.0000 MB /   5.00 sec =  709.4949 Mbps   275 retrans
>   442.0625 MB /   5.00 sec =  741.7008 Mbps    53 retrans
>   418.5625 MB /   5.00 sec =  702.1329 Mbps   133 retrans
>
>  1287.0080 MB /  15.08 sec =  715.9252 Mbps 1 %TX 30 %RX 461 retrans 0.43
> msRTT
>
>
>
> Testing download outside tunnel
>
>
>
>   552.4375 MB /   5.00 sec =  926.8347 Mbps    26 retrans
>   555.1875 MB /   5.00 sec =  931.4499 Mbps    17 retrans
>   553.0000 MB /   5.00 sec =  927.7802 Mbps    16 retrans
>
>  1664.2149 MB /  15.03 sec =  928.6737 Mbps 9 %TX 5 %RX 60 retrans 0.46
> msRTT
>
>
>
>
>
>
> Results of nuttcp test with rx-checksumming and tx-checksumming off:
>
>
>
> Testing upload inside tunnel
>
>
>
>   440.0000 MB /   5.00 sec =  738.0112 Mbps   117 retrans
>   433.0000 MB /   5.00 sec =  726.4892 Mbps   135 retrans
>   447.9375 MB /   5.00 sec =  751.5714 Mbps   112 retrans
>
>  1321.0069 MB /  15.04 sec =  736.7213 Mbps 3 %TX 21 %RX 364 retrans 0.51
> msRTT
>
>
>
> Testing download inside tunnel
>
>
>
>   494.0625 MB /   5.00 sec =  828.8973 Mbps   335 retrans
>   471.0000 MB /   5.00 sec =  790.2050 Mbps   219 retrans
>   469.8750 MB /   5.00 sec =  788.3174 Mbps   220 retrans
>
>  1435.1875 MB /  15.00 sec =  802.4203 Mbps 89 %TX 12 %RX 774 retrans 0.46
> msRTT
>
>
> Testing upload outside tunnel
>
>
>
>   431.2500 MB /   5.00 sec =  723.2808 Mbps    33 retrans
>   446.3750 MB /   5.00 sec =  748.9268 Mbps    10 retrans
>   475.4375 MB /   5.00 sec =  797.7044 Mbps     0 retrans
>
>  1355.0834 MB /  15.06 sec =  754.6438 Mbps 1 %TX 33 %RX 43 retrans 0.53
> msRTT
>
>
>
> Testing download outside tunnel
>
>
>
>   424.8125 MB /   5.00 sec =  712.7061 Mbps   102 retrans
>   456.5625 MB /   5.00 sec =  765.9872 Mbps    80 retrans
>   454.0000 MB /   5.00 sec =  761.6935 Mbps   116 retrans
>
>  1335.7823 MB /  15.01 sec =  746.6959 Mbps 4 %TX 5 %RX 298 retrans 0.55
> msRTT
