From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: TCP slowdown in 2.6.25?
Date: Mon, 28 Apr 2008 17:53:56 +0200
Message-ID: <1209398036.6904.31.camel@gentoo-jocke.transmode.se>
References: <1209384733.6904.12.camel@gentoo-jocke.transmode.se>
	 <1209389586.6904.17.camel@gentoo-jocke.transmode.se>
	 <Pine.LNX.4.64.0804281728280.1888@wrl-59.cs.helsinki.fi>
	 <1209395959.6904.25.camel@gentoo-jocke.transmode.se>
	 <Pine.LNX.4.64.0804281826260.1888@wrl-59.cs.helsinki.fi>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:48000 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1765183AbYD1Px7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 11:53:59 -0400
In-Reply-To: <Pine.LNX.4.64.0804281826260.1888@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-04-28 at 18:48 +0300, Ilpo J=E4rvinen wrote:
> On Mon, 28 Apr 2008, Joakim Tjernlund wrote:
>=20
> > On Mon, 2008-04-28 at 17:42 +0300, Ilpo J=E4rvinen wrote:
> > > On Mon, 28 Apr 2008, Joakim Tjernlund wrote:
> > > > On Mon, 2008-04-28 at 14:12 +0200, Joakim Tjernlund wrote:
> > > > > After upgrading from 2.6.23 to 2.6.25 I am seeing a big slow =
down on
> > > > > our old www server. Stracing shows lots of EAGAIN but i not s=
ure
> > > > > these are relevant. I got no idea where to start looking so
> > > > > I would appreciate some pointers. Perhaps this is a know issu=
e?
> > > > >=20
> > > > > CPU is a PowerPC, mpc8321, network driver ucc_geth
> > > >=20
> > > > Some info:
> > > > Even ftp transfers takes forever, but only in one direction: fr=
om the
> > > > node with kernel 2.6.25 to some other host. Strace show me that
> > > > write(2) hangs for long periods before succeeding to transmit=20
> > > > the data.
>=20
> > > To some specific or "any" other host? How long is "long"?
> >=20
> > Any host. A 1304632 bytes file takes about 110 seconds to transfer
> > (12 Kbytes/sec)
> >
> > A quick capture with wireshark indicates that some sent packages fr=
om
> > the node never reaches the host on the network.
>=20
> Thanks, this is the important bit of info, TCP flow control limit see=
ms=20
> just a consequence of that... ...Now we'll just have to figure out wh=
at is=20
> causing those losses.
>=20
> Is there some middlebox on the route to that host?

Yes, there is a router in between , but I have had reports that the
slowdown also happens without a router in between.

Here is a fragment from wireshark, hope it means something to you :)
Troble starts at frame 9

No.     Time        Source                Destination           Protoco=
l Info
      1 0.000000    192.168.101.13        192.168.1.15          FTP
Request: PORT 192,168,101,13,158,17

=46rame 1 (94 bytes on wire, 94 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 39399 (39399), Dst Port: ftp
(21), Seq: 1, Ack: 1, Len: 28
    Source port: 39399 (39399)
    Destination port: ftp (21)
    Sequence number: 1    (relative sequence number)
    [Next sequence number: 29    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x18 (PSH, ACK)
    Window size: 1460
    Checksum: 0xbe68 [correct]
    Options: (12 bytes)
=46ile Transfer Protocol (FTP)

No.     Time        Source                Destination           Protoco=
l
Info
      2 0.000064    192.168.1.15          192.168.101.13        FTP
Response: 200 PORT command successful. Consider using PASV.

=46rame 2 (117 bytes on wire, 117 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp (21), Dst Port: 39399
(39399), Seq: 1, Ack: 29, Len: 51
    Source port: ftp (21)
    Destination port: 39399 (39399)
    Sequence number: 1    (relative sequence number)
    [Next sequence number: 52    (relative sequence number)]
    Acknowledgement number: 29    (relative ack number)
    Header length: 32 bytes
    Flags: 0x18 (PSH, ACK)
    Window size: 46
    Checksum: 0xe7c6 [incorrect, should be 0x839d (maybe caused by "TCP
checksum offload"?)]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 1]
        [The RTT to ACK the segment was: 0.000064000 seconds]
=46ile Transfer Protocol (FTP)

No.     Time        Source                Destination           Protoco=
l
Info
      3 0.000739    192.168.101.13        192.168.1.15          TCP
39399 > ftp [ACK] Seq=3D29 Ack=3D52 Win=3D1460 Len=3D0 TSV=3D49341 TSER=
=3D7677016

=46rame 3 (66 bytes on wire, 66 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 39399 (39399), Dst Port: ftp
(21), Seq: 29, Ack: 52, Len: 0
    Source port: 39399 (39399)
    Destination port: ftp (21)
    Sequence number: 29    (relative sequence number)
    Acknowledgement number: 52    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 1460
    Checksum: 0x2945 [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 2]
        [The RTT to ACK the segment was: 0.000675000 seconds]

No.     Time        Source                Destination           Protoco=
l
Info
      4 0.001243    192.168.101.13        192.168.1.15          FTP
Request: STOR uImage

=46rame 4 (79 bytes on wire, 79 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 39399 (39399), Dst Port: ftp
(21), Seq: 29, Ack: 52, Len: 13
    Source port: 39399 (39399)
    Destination port: ftp (21)
    Sequence number: 29    (relative sequence number)
    [Next sequence number: 42    (relative sequence number)]
    Acknowledgement number: 52    (relative ack number)
    Header length: 32 bytes
    Flags: 0x18 (PSH, ACK)
    Window size: 1460
    Checksum: 0x4c32 [correct]
    Options: (12 bytes)
=46ile Transfer Protocol (FTP)

No.     Time        Source                Destination           Protoco=
l
Info
      5 0.004577    192.168.1.15          192.168.101.13        TCP
ftp-data > 40465 [SYN] Seq=3D0 Win=3D5840 Len=3D0 MSS=3D1460 TSV=3D7677=
017 TSER=3D0
WS=3D7

=46rame 5 (74 bytes on wire, 74 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 0, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 0    (relative sequence number)
    Header length: 40 bytes
    Flags: 0x02 (SYN)
    Window size: 5840
    Checksum: 0x77be [correct]
    Options: (20 bytes)

No.     Time        Source                Destination           Protoco=
l
Info
      6 0.005238    192.168.101.13        192.168.1.15          TCP
40465 > ftp-data [SYN, ACK] Seq=3D0 Ack=3D1 Win=3D5792 Len=3D0 MSS=3D14=
60
TSV=3D49341 TSER=3D7677017 WS=3D2

=46rame 6 (74 bytes on wire, 74 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 40465 (40465), Dst Port:
ftp-data (20), Seq: 0, Ack: 1, Len: 0
    Source port: 40465 (40465)
    Destination port: ftp-data (20)
    Sequence number: 0    (relative sequence number)
    Acknowledgement number: 1    (relative ack number)
    Header length: 40 bytes
    Flags: 0x12 (SYN, ACK)
    Window size: 5792
    Checksum: 0x1f9d [correct]
    Options: (20 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 5]
        [The RTT to ACK the segment was: 0.000661000 seconds]

No.     Time        Source                Destination           Protoco=
l
Info
      7 0.005248    192.168.1.15          192.168.101.13        TCP
ftp-data > 40465 [ACK] Seq=3D1 Ack=3D1 Win=3D5888 Len=3D0 TSV=3D7677017=
 TSER=3D49341

=46rame 7 (66 bytes on wire, 66 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 1, Ack: 1, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 1    (relative sequence number)
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 5888 (scaled)
    Checksum: 0x64d6 [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 6]
        [The RTT to ACK the segment was: 0.000010000 seconds]

No.     Time        Source                Destination           Protoco=
l
Info
      8 0.005281    192.168.1.15          192.168.101.13        FTP
Response: 150 Ok to send data.

=46rame 8 (88 bytes on wire, 88 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp (21), Dst Port: 39399
(39399), Seq: 52, Ack: 42, Len: 22
    Source port: ftp (21)
    Destination port: 39399 (39399)
    Sequence number: 52    (relative sequence number)
    [Next sequence number: 74    (relative sequence number)]
    Acknowledgement number: 42    (relative ack number)
    Header length: 32 bytes
    Flags: 0x18 (PSH, ACK)
    Window size: 46
    Checksum: 0xe7a9 [incorrect, should be 0x1c6f (maybe caused by "TCP
checksum offload"?)]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 4]
        [The RTT to ACK the segment was: 0.004038000 seconds]
=46ile Transfer Protocol (FTP)

No.     Time        Source                Destination           Protoco=
l
Info
      9 0.007732    192.168.101.13        192.168.1.15          FTP-DAT=
A
[TCP Previous segment lost] FTP Data: 1448 bytes

=46rame 9 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 40465 (40465), Dst Port:
ftp-data (20), Seq: 1449, Ack: 1, Len: 1448
    Source port: 40465 (40465)
    Destination port: ftp-data (20)
    Sequence number: 1449    (relative sequence number)
    [Next sequence number: 2897    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 5792 (scaled)
    Checksum: 0xc6b7 [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 7]
        [The RTT to ACK the segment was: 0.002484000 seconds]
        [TCP Analysis Flags]
            [A segment before this frame was lost]
=46TP Data

No.     Time        Source                Destination           Protoco=
l
Info
     10 0.007763    192.168.1.15          192.168.101.13        TCP
[TCP Dup ACK 7#1] ftp-data > 40465 [ACK] Seq=3D1 Ack=3D1 Win=3D5888 Len=
=3D0
TSV=3D7677018 TSER=3D49341 SLE=3D1449 SRE=3D2897

=46rame 10 (78 bytes on wire, 78 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 1, Ack: 1, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 1    (relative sequence number)
    Acknowledgement number: 1    (relative ack number)
    Header length: 44 bytes
    Flags: 0x10 (ACK)
    Window size: 5888 (scaled)
    Checksum: 0xeeb4 [correct]
    Options: (24 bytes)
    [SEQ/ACK analysis]
        [TCP Analysis Flags]
            [This is a TCP duplicate ack]
        [Duplicate ACK #: 1]
        [Duplicate to the ACK in frame: 7]

No.     Time        Source                Destination           Protoco=
l
Info
     11 0.038975    192.168.101.13        192.168.1.15          TCP
39399 > ftp [ACK] Seq=3D42 Ack=3D74 Win=3D1460 Len=3D0 TSV=3D49345 TSER=
=3D7677017

=46rame 11 (66 bytes on wire, 66 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 39399 (39399), Dst Port: ftp
(21), Seq: 42, Ack: 74, Len: 0
    Source port: 39399 (39399)
    Destination port: ftp (21)
    Sequence number: 42    (relative sequence number)
    Acknowledgement number: 74    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 1460
    Checksum: 0x291d [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 8]
        [The RTT to ACK the segment was: 0.033694000 seconds]

No.     Time        Source                Destination           Protoco=
l
Info
     12 0.209848    192.168.101.13        192.168.1.15          FTP-DAT=
A
[TCP Retransmission] FTP Data: 1448 bytes

=46rame 12 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 40465 (40465), Dst Port:
ftp-data (20), Seq: 1, Ack: 1, Len: 1448
    Source port: 40465 (40465)
    Destination port: ftp-data (20)
    Sequence number: 1    (relative sequence number)
    [Next sequence number: 1449    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 5792 (scaled)
    Checksum: 0x2760 [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 10]
        [The RTT to ACK the segment was: 0.202085000 seconds]
        [TCP Analysis Flags]
            [This frame is a (suspected) retransmission]
            [The RTO for this segment was: 0.202116000 seconds]
            [RTO based on delta from frame: 9]
=46TP Data

No.     Time        Source                Destination           Protoco=
l
Info
     13 0.209871    192.168.1.15          192.168.101.13        TCP
ftp-data > 40465 [ACK] Seq=3D1 Ack=3D2897 Win=3D8832 Len=3D0 TSV=3D7677=
068
TSER=3D49362

=46rame 13 (66 bytes on wire, 66 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 1, Ack: 2897, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 1    (relative sequence number)
    Acknowledgement number: 2897    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 8832 (scaled)
    Checksum: 0x5927 [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 9]
        [The RTT to ACK the segment was: 0.202139000 seconds]

No.     Time        Source                Destination           Protoco=
l
Info
     14 0.211347    192.168.101.13        192.168.1.15          FTP-DAT=
A
[TCP Previous segment lost] FTP Data: 1448 bytes

=46rame 14 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 40465 (40465), Dst Port:
ftp-data (20), Seq: 4345, Ack: 1, Len: 1448
    Source port: 40465 (40465)
    Destination port: ftp-data (20)
    Sequence number: 4345    (relative sequence number)
    [Next sequence number: 5793    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 5792 (scaled)
    Checksum: 0x166f [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 13]
        [The RTT to ACK the segment was: 0.001476000 seconds]
        [TCP Analysis Flags]
            [A segment before this frame was lost]
=46TP Data

No.     Time        Source                Destination           Protoco=
l
Info
     15 0.211360    192.168.1.15          192.168.101.13        TCP
[TCP Dup ACK 13#1] ftp-data > 40465 [ACK] Seq=3D1 Ack=3D2897 Win=3D8832=
 Len=3D0
TSV=3D7677069 TSER=3D49362 SLE=3D4345 SRE=3D5793

=46rame 15 (78 bytes on wire, 78 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 1, Ack: 2897, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 1    (relative sequence number)
    Acknowledgement number: 2897    (relative ack number)
    Header length: 44 bytes
    Flags: 0x10 (ACK)
    Window size: 8832 (scaled)
    Checksum: 0xcc65 [correct]
    Options: (24 bytes)
    [SEQ/ACK analysis]
        [TCP Analysis Flags]
            [This is a TCP duplicate ack]
        [Duplicate ACK #: 1]
        [Duplicate to the ACK in frame: 13]

No.     Time        Source                Destination           Protoco=
l
Info
     16 0.211596    192.168.101.13        192.168.1.15          FTP-DAT=
A
=46TP Data: 1448 bytes

=46rame 16 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 40465 (40465), Dst Port:
ftp-data (20), Seq: 5793, Ack: 1, Len: 1448
    Source port: 40465 (40465)
    Destination port: ftp-data (20)
    Sequence number: 5793    (relative sequence number)
    [Next sequence number: 7241    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 5792 (scaled)
    Checksum: 0x832a [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 15]
        [The RTT to ACK the segment was: 0.000236000 seconds]
=46TP Data

No.     Time        Source                Destination           Protoco=
l
Info
     17 0.211606    192.168.1.15          192.168.101.13        TCP
[TCP Dup ACK 13#2] ftp-data > 40465 [ACK] Seq=3D1 Ack=3D2897 Win=3D8832=
 Len=3D0
TSV=3D7677069 TSER=3D49362 SLE=3D4345 SRE=3D7241

=46rame 17 (78 bytes on wire, 78 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 1, Ack: 2897, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 1    (relative sequence number)
    Acknowledgement number: 2897    (relative ack number)
    Header length: 44 bytes
    Flags: 0x10 (ACK)
    Window size: 8832 (scaled)
    Checksum: 0xc6bd [correct]
    Options: (24 bytes)
    [SEQ/ACK analysis]
        [TCP Analysis Flags]
            [This is a TCP duplicate ack]
        [Duplicate ACK #: 2]
        [Duplicate to the ACK in frame: 13]

No.     Time        Source                Destination           Protoco=
l
Info
     18 0.212844    192.168.101.13        192.168.1.15          FTP-DAT=
A
=46TP Data: 1448 bytes

=46rame 18 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 40465 (40465), Dst Port:
ftp-data (20), Seq: 7241, Ack: 1, Len: 1448
    Source port: 40465 (40465)
    Destination port: ftp-data (20)
    Sequence number: 7241    (relative sequence number)
    [Next sequence number: 8689    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 5792 (scaled)
    Checksum: 0x7d4e [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 17]
        [The RTT to ACK the segment was: 0.001238000 seconds]
=46TP Data

No.     Time        Source                Destination           Protoco=
l
Info
     19 0.212854    192.168.1.15          192.168.101.13        TCP
[TCP Dup ACK 13#3] ftp-data > 40465 [ACK] Seq=3D1 Ack=3D2897 Win=3D8832=
 Len=3D0
TSV=3D7677069 TSER=3D49362 SLE=3D4345 SRE=3D8689

=46rame 19 (78 bytes on wire, 78 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 1, Ack: 2897, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 1    (relative sequence number)
    Acknowledgement number: 2897    (relative ack number)
    Header length: 44 bytes
    Flags: 0x10 (ACK)
    Window size: 8832 (scaled)
    Checksum: 0xc115 [correct]
    Options: (24 bytes)
    [SEQ/ACK analysis]
        [TCP Analysis Flags]
            [This is a TCP duplicate ack]
        [Duplicate ACK #: 3]
        [Duplicate to the ACK in frame: 13]

No.     Time        Source                Destination           Protoco=
l
Info
     20 0.213095    192.168.101.13        192.168.1.15          FTP-DAT=
A
=46TP Data: 1448 bytes

=46rame 20 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 40465 (40465), Dst Port:
ftp-data (20), Seq: 8689, Ack: 1, Len: 1448
    Source port: 40465 (40465)
    Destination port: ftp-data (20)
    Sequence number: 8689    (relative sequence number)
    [Next sequence number: 10137    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 5792 (scaled)
    Checksum: 0x6b7f [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 19]
        [The RTT to ACK the segment was: 0.000241000 seconds]
=46TP Data

No.     Time        Source                Destination           Protoco=
l
Info
     21 0.213105    192.168.1.15          192.168.101.13        TCP
[TCP Dup ACK 13#4] ftp-data > 40465 [ACK] Seq=3D1 Ack=3D2897 Win=3D8832=
 Len=3D0
TSV=3D7677069 TSER=3D49362 SLE=3D4345 SRE=3D10137

=46rame 21 (78 bytes on wire, 78 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 1, Ack: 2897, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 1    (relative sequence number)
    Acknowledgement number: 2897    (relative ack number)
    Header length: 44 bytes
    Flags: 0x10 (ACK)
    Window size: 8832 (scaled)
    Checksum: 0xbb6d [correct]
    Options: (24 bytes)
    [SEQ/ACK analysis]
        [TCP Analysis Flags]
            [This is a TCP duplicate ack]
        [Duplicate ACK #: 4]
        [Duplicate to the ACK in frame: 13]

No.     Time        Source                Destination           Protoco=
l
Info
     22 0.214345    192.168.101.13        192.168.1.15          FTP-DAT=
A
[TCP Fast Retransmission] FTP Data: 1448 bytes

=46rame 22 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 40465 (40465), Dst Port:
ftp-data (20), Seq: 2897, Ack: 1, Len: 1448
    Source port: 40465 (40465)
    Destination port: ftp-data (20)
    Sequence number: 2897    (relative sequence number)
    [Next sequence number: 4345    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x18 (PSH, ACK)
    Window size: 5792 (scaled)
    Checksum: 0x0799 [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 21]
        [The RTT to ACK the segment was: 0.001240000 seconds]
        [TCP Analysis Flags]
            [This frame is a (suspected) fast retransmission]
            [This frame is a (suspected) retransmission]
=46TP Data

No.     Time        Source                Destination           Protoco=
l
Info
     23 0.214360    192.168.1.15          192.168.101.13        TCP
ftp-data > 40465 [ACK] Seq=3D1 Ack=3D10137 Win=3D11648 Len=3D0 TSV=3D76=
77070
TSER=3D49362

=46rame 23 (66 bytes on wire, 66 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 1, Ack: 10137, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 1    (relative sequence number)
    Acknowledgement number: 10137    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 11648 (scaled)
    Checksum: 0x3cc7 [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 20]
        [The RTT to ACK the segment was: 0.001265000 seconds]

No.     Time        Source                Destination           Protoco=
l
Info
     24 0.215843    192.168.101.13        192.168.1.15          FTP-DAT=
A
[TCP Previous segment lost] FTP Data: 1448 bytes

=46rame 24 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 40465 (40465), Dst Port:
ftp-data (20), Seq: 11585, Ack: 1, Len: 1448
    Source port: 40465 (40465)
    Destination port: ftp-data (20)
    Sequence number: 11585    (relative sequence number)
    [Next sequence number: 13033    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x18 (PSH, ACK)
    Window size: 5792 (scaled)
    Checksum: 0x3791 [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 23]
        [The RTT to ACK the segment was: 0.001483000 seconds]
        [TCP Analysis Flags]
            [A segment before this frame was lost]
=46TP Data

No.     Time        Source                Destination           Protoco=
l
Info
     25 0.215854    192.168.1.15          192.168.101.13        TCP
[TCP Dup ACK 23#1] ftp-data > 40465 [ACK] Seq=3D1 Ack=3D10137 Win=3D116=
48
Len=3D0 TSV=3D7677070 TSER=3D49362 SLE=3D11585 SRE=3D13033

=46rame 25 (78 bytes on wire, 78 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 1, Ack: 10137, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 1    (relative sequence number)
    Acknowledgement number: 10137    (relative ack number)
    Header length: 44 bytes
    Flags: 0x10 (ACK)
    Window size: 11648 (scaled)
    Checksum: 0x7776 [correct]
    Options: (24 bytes)
    [SEQ/ACK analysis]
        [TCP Analysis Flags]
            [This is a TCP duplicate ack]
        [Duplicate ACK #: 1]
        [Duplicate to the ACK in frame: 23]

No.     Time        Source                Destination           Protoco=
l
Info
     26 0.839712    192.168.101.13        192.168.1.15          FTP-DAT=
A
[TCP Retransmission] FTP Data: 1448 bytes

=46rame 26 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 40465 (40465), Dst Port:
ftp-data (20), Seq: 10137, Ack: 1, Len: 1448
    Source port: 40465 (40465)
    Destination port: ftp-data (20)
    Sequence number: 10137    (relative sequence number)
    [Next sequence number: 11585    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x18 (PSH, ACK)
    Window size: 5792 (scaled)
    Checksum: 0xfd4c [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 25]
        [The RTT to ACK the segment was: 0.623858000 seconds]
        [TCP Analysis Flags]
            [This frame is a (suspected) retransmission]
            [The RTO for this segment was: 0.623869000 seconds]
            [RTO based on delta from frame: 24]
=46TP Data

No.     Time        Source                Destination           Protoco=
l
Info
     27 0.839767    192.168.1.15          192.168.101.13        TCP
ftp-data > 40465 [ACK] Seq=3D1 Ack=3D13033 Win=3D14592 Len=3D0 TSV=3D76=
77226
TSER=3D49425

=46rame 27 (66 bytes on wire, 66 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 1, Ack: 13033, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 1    (relative sequence number)
    Acknowledgement number: 13033    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 14592 (scaled)
    Checksum: 0x3085 [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 24]
        [The RTT to ACK the segment was: 0.623924000 seconds]

No.     Time        Source                Destination           Protoco=
l
Info
     28 0.841458    192.168.101.13        192.168.1.15          FTP-DAT=
A
[TCP Previous segment lost] FTP Data: 1448 bytes

=46rame 28 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 40465 (40465), Dst Port:
ftp-data (20), Seq: 14481, Ack: 1, Len: 1448
    Source port: 40465 (40465)
    Destination port: ftp-data (20)
    Sequence number: 14481    (relative sequence number)
    [Next sequence number: 15929    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 5792 (scaled)
    Checksum: 0x35c8 [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 27]
        [The RTT to ACK the segment was: 0.001691000 seconds]
        [TCP Analysis Flags]
            [A segment before this frame was lost]
=46TP Data

No.     Time        Source                Destination           Protoco=
l
Info
     29 0.841471    192.168.1.15          192.168.101.13        TCP
[TCP Dup ACK 27#1] ftp-data > 40465 [ACK] Seq=3D1 Ack=3D13033 Win=3D145=
92
Len=3D0 TSV=3D7677226 TSER=3D49425 SLE=3D14481 SRE=3D15929

=46rame 29 (78 bytes on wire, 78 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 1, Ack: 13033, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 1    (relative sequence number)
    Acknowledgement number: 13033    (relative ack number)
    Header length: 44 bytes
    Flags: 0x10 (ACK)
    Window size: 14592 (scaled)
    Checksum: 0x5494 [correct]
    Options: (24 bytes)
    [SEQ/ACK analysis]
        [TCP Analysis Flags]
            [This is a TCP duplicate ack]
        [Duplicate ACK #: 1]
        [Duplicate to the ACK in frame: 27]

No.     Time        Source                Destination           Protoco=
l
Info
     30 0.842958    192.168.101.13        192.168.1.15          FTP-DAT=
A
=46TP Data: 1448 bytes

=46rame 30 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 40465 (40465), Dst Port:
ftp-data (20), Seq: 15929, Ack: 1, Len: 1448
    Source port: 40465 (40465)
    Destination port: ftp-data (20)
    Sequence number: 15929    (relative sequence number)
    [Next sequence number: 17377    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 5792 (scaled)
    Checksum: 0x9c77 [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 29]
        [The RTT to ACK the segment was: 0.001487000 seconds]
=46TP Data

No.     Time        Source                Destination           Protoco=
l
Info
     31 0.842969    192.168.1.15          192.168.101.13        TCP
[TCP Dup ACK 27#2] ftp-data > 40465 [ACK] Seq=3D1 Ack=3D13033 Win=3D145=
92
Len=3D0 TSV=3D7677227 TSER=3D49425 SLE=3D14481 SRE=3D17377

=46rame 31 (78 bytes on wire, 78 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 1, Ack: 13033, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 1    (relative sequence number)
    Acknowledgement number: 13033    (relative ack number)
    Header length: 44 bytes
    Flags: 0x10 (ACK)
    Window size: 14592 (scaled)
    Checksum: 0x4eeb [correct]
    Options: (24 bytes)
    [SEQ/ACK analysis]
        [TCP Analysis Flags]
            [This is a TCP duplicate ack]
        [Duplicate ACK #: 2]
        [Duplicate to the ACK in frame: 27]

No.     Time        Source                Destination           Protoco=
l
Info
     32 1.049833    192.168.101.13        192.168.1.15          FTP-DAT=
A
[TCP Retransmission] FTP Data: 1448 bytes

=46rame 32 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 40465 (40465), Dst Port:
ftp-data (20), Seq: 13033, Ack: 1, Len: 1448
    Source port: 40465 (40465)
    Destination port: ftp-data (20)
    Sequence number: 13033    (relative sequence number)
    [Next sequence number: 14481    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 5792 (scaled)
    Checksum: 0xb312 [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 31]
        [The RTT to ACK the segment was: 0.206864000 seconds]
        [TCP Analysis Flags]
            [This frame is a (suspected) retransmission]
            [The RTO for this segment was: 0.206875000 seconds]
            [RTO based on delta from frame: 30]
=46TP Data

No.     Time        Source                Destination           Protoco=
l
Info
     33 1.049863    192.168.1.15          192.168.101.13        TCP
ftp-data > 40465 [ACK] Seq=3D1 Ack=3D17377 Win=3D17536 Len=3D0 TSV=3D76=
77278
TSER=3D49446

=46rame 33 (66 bytes on wire, 66 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 1, Ack: 17377, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 1    (relative sequence number)
    Acknowledgement number: 17377    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 17536 (scaled)
    Checksum: 0x1f2d [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 30]
        [The RTT to ACK the segment was: 0.206905000 seconds]

No.     Time        Source                Destination           Protoco=
l
Info
     34 1.051331    192.168.101.13        192.168.1.15          FTP-DAT=
A
[TCP Previous segment lost] FTP Data: 1448 bytes

=46rame 34 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 40465 (40465), Dst Port:
ftp-data (20), Seq: 18825, Ack: 1, Len: 1448
    Source port: 40465 (40465)
    Destination port: ftp-data (20)
    Sequence number: 18825    (relative sequence number)
    [Next sequence number: 20273    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 5792 (scaled)
    Checksum: 0xb6a5 [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 33]
        [The RTT to ACK the segment was: 0.001468000 seconds]
        [TCP Analysis Flags]
            [A segment before this frame was lost]
=46TP Data

No.     Time        Source                Destination           Protoco=
l
Info
     35 1.051356    192.168.1.15          192.168.101.13        TCP
[TCP Dup ACK 33#1] ftp-data > 40465 [ACK] Seq=3D1 Ack=3D17377 Win=3D175=
36
Len=3D0 TSV=3D7677279 TSER=3D49446 SLE=3D18825 SRE=3D20273

=46rame 35 (78 bytes on wire, 78 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 1, Ack: 17377, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 1    (relative sequence number)
    Acknowledgement number: 17377    (relative ack number)
    Header length: 44 bytes
    Flags: 0x10 (ACK)
    Window size: 17536 (scaled)
    Checksum: 0x214b [correct]
    Options: (24 bytes)
    [SEQ/ACK analysis]
        [TCP Analysis Flags]
            [This is a TCP duplicate ack]
        [Duplicate ACK #: 1]
        [Duplicate to the ACK in frame: 33]

No.     Time        Source                Destination           Protoco=
l
Info
     36 1.053083    192.168.101.13        192.168.1.15          FTP-DAT=
A
[TCP Previous segment lost] FTP Data: 1448 bytes

=46rame 36 (1514 bytes on wire, 1514 bytes captured)
Ethernet II, Src: HewlettP_47:49:46 (00:1c:c4:47:49:46), Dst:
G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29)
Internet Protocol, Src: 192.168.101.13 (192.168.101.13), Dst:
192.168.1.15 (192.168.1.15)
Transmission Control Protocol, Src Port: 40465 (40465), Dst Port:
ftp-data (20), Seq: 23169, Ack: 1, Len: 1448
    Source port: 40465 (40465)
    Destination port: ftp-data (20)
    Sequence number: 23169    (relative sequence number)
    [Next sequence number: 24617    (relative sequence number)]
    Acknowledgement number: 1    (relative ack number)
    Header length: 32 bytes
    Flags: 0x10 (ACK)
    Window size: 5792 (scaled)
    Checksum: 0xeccc [correct]
    Options: (12 bytes)
    [SEQ/ACK analysis]
        [This is an ACK to the segment in frame: 35]
        [The RTT to ACK the segment was: 0.001727000 seconds]
        [TCP Analysis Flags]
            [A segment before this frame was lost]
=46TP Data

No.     Time        Source                Destination           Protoco=
l
Info
     37 1.053094    192.168.1.15          192.168.101.13        TCP
[TCP Dup ACK 33#2] ftp-data > 40465 [ACK] Seq=3D1 Ack=3D17377 Win=3D175=
36
Len=3D0 TSV=3D7677279 TSER=3D49446 SLE=3D23169 SRE=3D24617 SLE=3D18825 =
SRE=3D20273

=46rame 37 (86 bytes on wire, 86 bytes captured)
Ethernet II, Src: G-ProCom_2f:ed:29 (00:0f:fe:2f:ed:29), Dst:
D-Link_53:3b:0c (00:0d:88:53:3b:0c)
Internet Protocol, Src: 192.168.1.15 (192.168.1.15), Dst: 192.168.101.1=
3
(192.168.101.13)
Transmission Control Protocol, Src Port: ftp-data (20), Dst Port: 40465
(40465), Seq: 1, Ack: 17377, Len: 0
    Source port: ftp-data (20)
    Destination port: 40465 (40465)
    Sequence number: 1    (relative sequence number)
    Acknowledgement number: 17377    (relative ack number)
    Header length: 52 bytes
    Flags: 0x10 (ACK)
    Window size: 17536 (scaled)
    Checksum: 0x1781 [correct]
    Options: (32 bytes)
    [SEQ/ACK analysis]
        [TCP Analysis Flags]
            [This is a TCP duplicate ack]
        [Duplicate ACK #: 2]
        [Duplicate to the ACK in frame: 33]



>=20
>=20
> --=20
>  i.
