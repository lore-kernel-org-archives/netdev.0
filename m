From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH 0/6] sctp: Auto-ASCONF patch series
Date: Wed, 27 Apr 2011 17:28:49 +0800
Message-ID: <4DB7E1D1.8030104@cn.fujitsu.com>
References: <AC642DCE-402B-496B-B519-679335A13211@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58530 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752227Ab1D0J3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 05:29:08 -0400
In-Reply-To: <AC642DCE-402B-496B-B519-679335A13211@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From 9ede9db0ec4b03d3061a5bfed78328cb5528b908 Mon Sep 17 00:00:00 2001
> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: Wed, 27 Apr 2011 17:16:21 +0900
> Subject: [PATCH 0/6] sctp: Auto-ASCONF patch series
>
> Series of 6 patches to support auto_asconf and the other related functionalities that auto_asconf relies on. 
>
> Michio Honda (5):
>   sctp: Add ADD/DEL ASCONF handling at the receiver.
>   sctp: Add Auto-ASCONF support (core).
>   sctp: Add sysctl support for Auto-ASCONF.
>   sctp: Add socket option operation for Auto-ASCONF.
>   sctp: sctp: Add ASCONF operation on the single-homed host
>
> YOSHIFUJI Hideaki (1):
>   sctp: Allow regular C expression in 4th argument for
>     SCTP_DEBUG_PRINTK_IPADDR macro.


When I test this patchset using IPv4 only socket,
Host1:
#sctp_test -H 0.0.0.0 -P 9000 -l
Host2:
#sctp_test -H 0.0.0.0 -P 9000 -h 192.168.0.19 -p 9000 -s -x 1 -D -T
I got following unexpected thing, IPv6 address be added to the asoc.

Frame 3 (118 bytes on wire, 118 bytes captured)
    Arrival Time: Apr 27, 2011 17:17:59.572897000
    [Time delta from previous captured frame: 13.804056000 seconds]
    [Time delta from previous displayed frame: 13.804056000 seconds]
    [Time since reference or first frame: 13.804105000 seconds]
    Frame Number: 3
    Frame Length: 118 bytes
    Capture Length: 118 bytes
    [Frame is marked: False]
    [Protocols in frame: eth:ip:sctp]
Ethernet II, Src: RealtekU_1a:f0:5c (52:54:00:1a:f0:5c), Dst: RealtekU_21:3c:7c (52:54:00:21:3c:7c)
    Destination: RealtekU_21:3c:7c (52:54:00:21:3c:7c)
        Address: RealtekU_21:3c:7c (52:54:00:21:3c:7c)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered address (this is NOT the factory default)
    Source: RealtekU_1a:f0:5c (52:54:00:1a:f0:5c)
        Address: RealtekU_1a:f0:5c (52:54:00:1a:f0:5c)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered address (this is NOT the factory default)
    Type: IP (0x0800)
Internet Protocol, Src: 192.168.0.21 (192.168.0.21), Dst: 192.168.0.19 (192.168.0.19)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x02 (DSCP 0x00: Default; ECN: 0x02)
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..1. = ECN-Capable Transport (ECT): 1
        .... ...0 = ECN-CE: 0
    Total Length: 104
    Identification: 0x001e (30)
    Flags: 0x02 (Don't Fragment)
        0.. = Reserved bit: Not Set
        .1. = Don't fragment: Set
        ..0 = More fragments: Not Set
    Fragment offset: 0
    Time to live: 64
    Protocol: SCTP (0x84)
    Header checksum: 0xb879 [correct]
        [Good: True]
        [Bad : False]
    Source: 192.168.0.21 (192.168.0.21)
    Destination: 192.168.0.19 (192.168.0.19)
Stream Control Transmission Protocol, Src Port: 9000 (9000), Dst Port: 9000 (9000)
    Source port: 9000
    Destination port: 9000
    Verification tag: 0x2b1e0377
    Checksum: 0x2a2e5aff (not verified)
    AUTH chunk
        Chunk type: AUTH (15)
            0... .... = Bit: Stop processing of the packet
            .0.. .... = Bit: Do not report
        Chunk flags: 0x00
        Chunk length: 28
        Shared key identifier: 0
        HMAC identifier: SHA-1 (1)
        HMAC: AA21B3835E1069FBFFA3589B1EB4C0AE47021F15
    ASCONF chunk
        Chunk type: ASCONF (193)
            1... .... = Bit: Skip chunk and continue processing of the packet
            .1.. .... = Bit: Do report
        Chunk flags: 0x00
        Chunk length: 44
        Serial number: 0xfa0b220b
        IPv4 address parameter (Address: 192.168.1.21)
            Parameter type: IPv4 address (0x0005)
                0... .... .... .... = Bit: Stop processing of chunk
                .0.. .... .... .... = Bit: Do not report
            Parameter length: 8
            IP Version 4 address: 192.168.1.21 (192.168.1.21)
        Delete IP address parameter (Address: 3ffe:501:ffff:101:5054:ff:fe70:993d, correlation ID: 0)
            Parameter type: Delete IP address (0xc002)
                1... .... .... .... = Bit: Skip parameter and continue processing of the chunk
                .1.. .... .... .... = Bit: Do report
            Parameter length: 28
            Correlation_id: 0x00000000
            IPv6 address parameter (Address: 3ffe:501:ffff:101:5054:ff:fe70:993d)
                Parameter type: IPv6 address (0x0006)
                    0... .... .... .... = Bit: Stop processing of chunk
                    .0.. .... .... .... = Bit: Do not report
                Parameter length: 20
                IP Version 6 address: 3ffe:501:ffff:101:5054:ff:fe70:993d (3ffe:501:ffff:101:5054:ff:fe70:993d)

No.     Time        Source                Destination           Protocol Info
      4 13.804193   192.168.0.19          192.168.0.21          SCTP     AUTH ASCONF_ACK 

Frame 4 (122 bytes on wire, 122 bytes captured)
    Arrival Time: Apr 27, 2011 17:17:59.572985000
    [Time delta from previous captured frame: 0.000088000 seconds]
    [Time delta from previous displayed frame: 0.000088000 seconds]
    [Time since reference or first frame: 13.804193000 seconds]
    Frame Number: 4
    Frame Length: 122 bytes
    Capture Length: 122 bytes
    [Frame is marked: False]
    [Protocols in frame: eth:ip:sctp]
Ethernet II, Src: RealtekU_21:3c:7c (52:54:00:21:3c:7c), Dst: RealtekU_1a:f0:5c (52:54:00:1a:f0:5c)
    Destination: RealtekU_1a:f0:5c (52:54:00:1a:f0:5c)
        Address: RealtekU_1a:f0:5c (52:54:00:1a:f0:5c)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered address (this is NOT the factory default)
    Source: RealtekU_21:3c:7c (52:54:00:21:3c:7c)
        Address: RealtekU_21:3c:7c (52:54:00:21:3c:7c)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered address (this is NOT the factory default)
    Type: IP (0x0800)
Internet Protocol, Src: 192.168.0.19 (192.168.0.19), Dst: 192.168.0.21 (192.168.0.21)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x02 (DSCP 0x00: Default; ECN: 0x02)
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..1. = ECN-Capable Transport (ECT): 1
        .... ...0 = ECN-CE: 0
    Total Length: 108
    Identification: 0x0000 (0)
    Flags: 0x02 (Don't Fragment)
        0.. = Reserved bit: Not Set
        .1. = Don't fragment: Set
        ..0 = More fragments: Not Set
    Fragment offset: 0
    Time to live: 64
    Protocol: SCTP (0x84)
    Header checksum: 0xb893 [correct]
        [Good: True]
        [Bad : False]
    Source: 192.168.0.19 (192.168.0.19)
    Destination: 192.168.0.21 (192.168.0.21)
Stream Control Transmission Protocol, Src Port: 9000 (9000), Dst Port: 9000 (9000)
    Source port: 9000
    Destination port: 9000
    Verification tag: 0x1b2d2288
    Checksum: 0x9b288dab (not verified)
    AUTH chunk
        Chunk type: AUTH (15)
            0... .... = Bit: Stop processing of the packet
            .0.. .... = Bit: Do not report
        Chunk flags: 0x00
        Chunk length: 28
        Shared key identifier: 0
        HMAC identifier: SHA-1 (1)
        HMAC: DDB8D3766671957FABA3554DE588599C9624DCBB
    ASCONF_ACK chunk
        Chunk type: ASCONF_ACK (128)
            1... .... = Bit: Skip chunk and continue processing of the packet
            .0.. .... = Bit: Do not report
        Chunk flags: 0x00
        Chunk length: 48
        Serial number: 0xfa0b220b
        Error cause indication parameter
            Parameter type: Error cause indication (0xc003)
                1... .... .... .... = Bit: Skip parameter and continue processing of the chunk
                .1.. .... .... .... = Bit: Do report
            Parameter length: 40
            Correlation_id: 0x00000000
            Unresolvable address cause (Address: )
                Cause code: Unresolvable address (0x0005)
                Cause length: 32
                Delete IP address parameter (Address: 3ffe:501:ffff:101:5054:ff:fe70:993d, correlation ID: 0)
                    Parameter type: Delete IP address (0xc002)
                        1... .... .... .... = Bit: Skip parameter and continue processing of the chunk
                        .1.. .... .... .... = Bit: Do report
                    Parameter length: 28
                    Correlation_id: 0x00000000
                    IPv6 address parameter (Address: 3ffe:501:ffff:101:5054:ff:fe70:993d)
                        Parameter type: IPv6 address (0x0006)
                            0... .... .... .... = Bit: Stop processing of chunk
                            .0.. .... .... .... = Bit: Do not report
                        Parameter length: 20
                        IP Version 6 address: 3ffe:501:ffff:101:5054:ff:fe70:993d (3ffe:501:ffff:101:5054:ff:fe70:993d)
Frame 5 (118 bytes on wire, 118 bytes captured)
    Arrival Time: Apr 27, 2011 17:17:59.573941000
    [Time delta from previous captured frame: 0.000956000 seconds]
    [Time delta from previous displayed frame: 0.000956000 seconds]
    [Time since reference or first frame: 13.805149000 seconds]
    Frame Number: 5
    Frame Length: 118 bytes
    Capture Length: 118 bytes
    [Frame is marked: False]
    [Protocols in frame: eth:ip:sctp]
Ethernet II, Src: RealtekU_1a:f0:5c (52:54:00:1a:f0:5c), Dst: RealtekU_21:3c:7c (52:54:00:21:3c:7c)
    Destination: RealtekU_21:3c:7c (52:54:00:21:3c:7c)
        Address: RealtekU_21:3c:7c (52:54:00:21:3c:7c)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered address (this is NOT the factory default)
    Source: RealtekU_1a:f0:5c (52:54:00:1a:f0:5c)
        Address: RealtekU_1a:f0:5c (52:54:00:1a:f0:5c)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered address (this is NOT the factory default)
    Type: IP (0x0800)
Internet Protocol, Src: 192.168.0.21 (192.168.0.21), Dst: 192.168.0.19 (192.168.0.19)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x02 (DSCP 0x00: Default; ECN: 0x02)
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..1. = ECN-Capable Transport (ECT): 1
        .... ...0 = ECN-CE: 0
    Total Length: 104
    Identification: 0x001f (31)
    Flags: 0x02 (Don't Fragment)
        0.. = Reserved bit: Not Set
        .1. = Don't fragment: Set
        ..0 = More fragments: Not Set
    Fragment offset: 0
    Time to live: 64
    Protocol: SCTP (0x84)
    Header checksum: 0xb878 [correct]
        [Good: True]
        [Bad : False]
    Source: 192.168.0.21 (192.168.0.21)
    Destination: 192.168.0.19 (192.168.0.19)
Stream Control Transmission Protocol, Src Port: 9000 (9000), Dst Port: 9000 (9000)
    Source port: 9000
    Destination port: 9000
    Verification tag: 0x2b1e0377
    Checksum: 0x91cfddc0 (not verified)
    AUTH chunk
        Chunk type: AUTH (15)
            0... .... = Bit: Stop processing of the packet
            .0.. .... = Bit: Do not report
        Chunk flags: 0x00
        Chunk length: 28
        Shared key identifier: 0
        HMAC identifier: SHA-1 (1)
        HMAC: 2293892E2642A2D0E8911A669761E86134A47BD0
    ASCONF chunk
        Chunk type: ASCONF (193)
            1... .... = Bit: Skip chunk and continue processing of the packet
            .1.. .... = Bit: Do report
        Chunk flags: 0x00
        Chunk length: 44
        Serial number: 0xfa0b220c
        IPv6 address parameter (Address: 3ffe:501:ffff:101:5054:ff:fe70:993d)
            Parameter type: IPv6 address (0x0006)
                0... .... .... .... = Bit: Stop processing of chunk
                .0.. .... .... .... = Bit: Do not report
            Parameter length: 20
            IP Version 6 address: 3ffe:501:ffff:101:5054:ff:fe70:993d (3ffe:501:ffff:101:5054:ff:fe70:993d)
        Delete IP address parameter (Address: 192.168.1.21, correlation ID: 0)
            Parameter type: Delete IP address (0xc002)
                1... .... .... .... = Bit: Skip parameter and continue processing of the chunk
                .1.. .... .... .... = Bit: Do report
            Parameter length: 16
            Correlation_id: 0x00000000
            IPv4 address parameter (Address: 192.168.1.21)
                Parameter type: IPv4 address (0x0005)
                    0... .... .... .... = Bit: Stop processing of chunk
                    .0.. .... .... .... = Bit: Do not report
                Parameter length: 8
                IP Version 4 address: 192.168.1.21 (192.168.1.21)

No.     Time        Source                Destination           Protocol Info
      6 13.805190   192.168.0.19          192.168.0.21          SCTP     AUTH ASCONF_ACK 

Frame 6 (82 bytes on wire, 82 bytes captured)
    Arrival Time: Apr 27, 2011 17:17:59.573982000
    [Time delta from previous captured frame: 0.000041000 seconds]
    [Time delta from previous displayed frame: 0.000041000 seconds]
    [Time since reference or first frame: 13.805190000 seconds]
    Frame Number: 6
    Frame Length: 82 bytes
    Capture Length: 82 bytes
    [Frame is marked: False]
    [Protocols in frame: eth:ip:sctp]
Ethernet II, Src: RealtekU_21:3c:7c (52:54:00:21:3c:7c), Dst: RealtekU_1a:f0:5c (52:54:00:1a:f0:5c)
    Destination: RealtekU_1a:f0:5c (52:54:00:1a:f0:5c)
        Address: RealtekU_1a:f0:5c (52:54:00:1a:f0:5c)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered address (this is NOT the factory default)
    Source: RealtekU_21:3c:7c (52:54:00:21:3c:7c)
        Address: RealtekU_21:3c:7c (52:54:00:21:3c:7c)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
        .... ..1. .... .... .... .... = LG bit: Locally administered address (this is NOT the factory default)
    Type: IP (0x0800)
Internet Protocol, Src: 192.168.0.19 (192.168.0.19), Dst: 192.168.0.21 (192.168.0.21)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x02 (DSCP 0x00: Default; ECN: 0x02)
        0000 00.. = Differentiated Services Codepoint: Default (0x00)
        .... ..1. = ECN-Capable Transport (ECT): 1
        .... ...0 = ECN-CE: 0
    Total Length: 68
    Identification: 0x0000 (0)
    Flags: 0x02 (Don't Fragment)
        0.. = Reserved bit: Not Set
        .1. = Don't fragment: Set
        ..0 = More fragments: Not Set
    Fragment offset: 0
    Time to live: 64
    Protocol: SCTP (0x84)
    Header checksum: 0xb8bb [correct]
        [Good: True]
        [Bad : False]
    Source: 192.168.0.19 (192.168.0.19)
    Destination: 192.168.0.21 (192.168.0.21)
Stream Control Transmission Protocol, Src Port: 9000 (9000), Dst Port: 9000 (9000)
    Source port: 9000
    Destination port: 9000
    Verification tag: 0x1b2d2288
    Checksum: 0x0962e46c (not verified)
    AUTH chunk
        Chunk type: AUTH (15)
            0... .... = Bit: Stop processing of the packet
            .0.. .... = Bit: Do not report
        Chunk flags: 0x00
        Chunk length: 28
        Shared key identifier: 0
        HMAC identifier: SHA-1 (1)
        HMAC: DBE65D3AB3FB77D29FE2870BBB9ECCE4DC6D5EB6
    ASCONF_ACK chunk
        Chunk type: ASCONF_ACK (128)
            1... .... = Bit: Skip chunk and continue processing of the packet
            .0.. .... = Bit: Do not report
        Chunk flags: 0x00
        Chunk length: 8
        Serial number: 0xfa0b220c

