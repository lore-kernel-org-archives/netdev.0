From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 109471] New: Linux generating invalid Ethernet frames
 which get dropped (as over-size) by gateway
Date: Wed, 16 Dec 2015 07:57:05 -0800
Message-ID: <20151216075705.3dcfafa7@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35624 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965780AbbLPP45 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 10:56:57 -0500
Received: by mail-pa0-f45.google.com with SMTP id tl7so3241488pab.2
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 07:56:57 -0800 (PST)
Received: from xeon-e3 (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id t85sm5738209pfa.34.2015.12.16.07.56.56
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 07:56:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

User error, but someone could help them out.

Begin forwarded message:

Date: Wed, 16 Dec 2015 15:47:16 +0000
=46rom: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla=
=2Ekernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 109471] New: Linux generating invalid Ethernet frames whi=
ch get dropped (as over-size) by gateway


https://bugzilla.kernel.org/show_bug.cgi?id=3D109471

            Bug ID: 109471
           Summary: Linux generating invalid Ethernet frames which get
                    dropped (as over-size) by gateway
           Product: Networking
           Version: 2.5
    Kernel Version: 3.18.11-v7+ #781 SMP PREEMPT armv7l GNU/Linux
          Hardware: ARM
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: linuxbrad@gmail.com
        Regression: No

Also described in detail here:
http://networkengineering.stackexchange.com/questions/25254/1522-byte-f=
rames-from-access-point-being-dropped-by-gateway=20

I configured the Linux device in question (Raspberry Pi 2b) as a hostap=
 WIFI
access point. Wifi clients connect and can sometimes transfer some data=
 but as
soon as the packet flow reaches a frame size of 1522 the flow stops - t=
he
gateway starts showing a spike in dropped frames (reflected in
/sys/class/net/eth0  /statistics/rx_length_errors) as the client retran=
smits
the dropped packets. A closer look shows that the gateway is dropping t=
he
packets due to size.=20

The TCP/IP part of the packet is 1500 bytes and I expect framing to add=
 a final
14 or 18 bytes before transmitting it onto the wire. However 22 bytes a=
re being
added, and it seems to be too many.


I have packet captures available to send via email (I'd like to not att=
ach them
for privacy reasons).=20


The following is a sample oversized packet as exported from Wireshark. =
Note
that I tweaked the MAC and IP addresses for privacy.


No.     Time            Source                Destination           Pro=
tocol
Length Info
     35 21:55:21.644314 192.168.1.149        54.239.25.200         TCP =
   =20
1522   [TCP Retransmission] 44053=E2=86=92443 [ACK] Seq=3D350 Ack=3D155=
 Win=3D88832 Len=3D1460
[ETHERNET FRAME CHECK SEQUENCE INCORRECT]

=46rame 35: 1522 bytes on wire (12176 bits), 1522 bytes captured (12176=
 bits)
    Encapsulation type: Ethernet (1)
    Arrival Time: Dec 15, 2015 21:55:21.644314000 EST
    [Time shift for this packet: 0.000000000 seconds]
    Epoch Time: 1450234521.644314000 seconds
    [Time delta from previous captured frame: 0.150820000 seconds]
    [Time delta from previous displayed frame: 3.683211000 seconds]
    [Time since reference or first frame: 9.568260000 seconds]
    Frame Number: 35
    Frame Length: 1522 bytes (12176 bits)
    Capture Length: 1522 bytes (12176 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: eth:ethertype:ip:tcp]
    [Coloring Rule Name: Bad TCP]
    [Coloring Rule String: tcp.analysis.flags && !tcp.analysis.window_u=
pdate]
Ethernet II, Src: xx:xx:xx:xx:xx:xx (xx:xx:xx:xx:xx:xx), Dst: Raspberr_=
xx:xx:xx
(xx:xx:xx:xx:xx:xx)
    Destination: Raspberr_xx:xx:xx (xx:xx:xx:xx:xx:xx)
        Address: Raspberr_xx:xx:xx (xx:xx:xx:xx:xx:xx)
        .... ..0. .... .... .... .... =3D LG bit: Globally unique addre=
ss
(factory default)
        .... ...0 .... .... .... .... =3D IG bit: Individual address (u=
nicast)
    Source: xx:xx:xx:xx:xx:xx (xx:xx:xx:xx:xx:xx)
        Address: xx:xx:xx:xx:xx:xx (xx:xx:xx:xx:xx:xx)
        .... ..0. .... .... .... .... =3D LG bit: Globally unique addre=
ss
(factory default)
        .... ...0 .... .... .... .... =3D IG bit: Individual address (u=
nicast)
    Type: IP (0x0800)
    Trailer: 2f8e4de5
    Frame check sequence: 0x29f37f68 [incorrect, should be 0x3b863a28]
        [FCS Good: False]
        [FCS Bad: True]
            [Expert Info (Error/Checksum): Bad checksum]
                [Bad checksum]
                [Severity level: Error]
                [Group: Checksum]
Internet Protocol Version 4, Src: 192.168.1.149 (192.168.1.149), Dst:
54.239.25.200 (54.239.25.200)
    Version: 4
    Header Length: 20 bytes
    Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00:=
 Not-ECT
(Not ECN-Capable Transport))
        0000 00.. =3D Differentiated Services Codepoint: Default (0x00)
        .... ..00 =3D Explicit Congestion Notification: Not-ECT (Not EC=
N-Capable
Transport) (0x00)
    Total Length: 1500
    Identification: 0xaaf3 (43763)
    Flags: 0x02 (Don't Fragment)
        0... .... =3D Reserved bit: Not set
        .1.. .... =3D Don't fragment: Set
        ..0. .... =3D More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: TCP (6)
    Header checksum: 0x3234 [validation disabled]
        [Good: False]
        [Bad: False]
    Source: 192.168.1.149 (192.168.1.149)
    Destination: 54.239.25.200 (54.239.25.200)
    [Source GeoIP: Unknown]
    [Destination GeoIP: Unknown]
Transmission Control Protocol, Src Port: 44053 (44053), Dst Port: 443 (=
443),
Seq: 350, Ack: 155, Len: 1460
    Source Port: 44053 (44053)
    Destination Port: 443 (443)
    [Stream index: 1]
    [TCP Segment Len: 1460]
    Sequence number: 350    (relative sequence number)
    [Next sequence number: 1810    (relative sequence number)]
    Acknowledgment number: 155    (relative ack number)
    Header Length: 20 bytes
    .... 0000 0001 0000 =3D Flags: 0x010 (ACK)
        000. .... .... =3D Reserved: Not set
        ...0 .... .... =3D Nonce: Not set
        .... 0... .... =3D Congestion Window Reduced (CWR): Not set
        .... .0.. .... =3D ECN-Echo: Not set
        .... ..0. .... =3D Urgent: Not set
        .... ...1 .... =3D Acknowledgment: Set
        .... .... 0... =3D Push: Not set
        .... .... .0.. =3D Reset: Not set
        .... .... ..0. =3D Syn: Not set
        .... .... ...0 =3D Fin: Not set
    Window size value: 347
    [Calculated window size: 88832]
    [Window size scaling factor: 256]
    Checksum: 0x1c58 [validation disabled]
        [Good Checksum: False]
        [Bad Checksum: False]
    Urgent pointer: 0
    [SEQ/ACK analysis]
        [iRTT: 0.028704000 seconds]
        [Bytes in flight: 2077]
        [TCP Analysis Flags]
            [Expert Info (Note/Sequence): This frame is a (suspected)
retransmission]
                [This frame is a (suspected) retransmission]
                [Severity level: Note]
                [Group: Sequence]
            [The RTO for this segment was: 7.247571000 seconds]
            [RTO based on delta from frame: 12]
    Retransmitted TCP segment data (1460 bytes)

--=20
You are receiving this mail because:
You are the assignee for the bug.
