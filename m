From: Harald Welte <laforge@gnumonks.org>
Subject: corruption of ICMP payload while forwarding
Date: Tue, 6 Jul 2004 14:29:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706122942.GC32707@sunbeam2>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tzZdJ4yHDV5r1Akt"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--tzZdJ4yHDV5r1Akt
Content-Type: multipart/mixed; boundary="FhKpTYimqQF2+bfE"
Content-Disposition: inline


--FhKpTYimqQF2+bfE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

I'm observing a quite strange phenomenon on one of the larger linux
firewall deployments (Xeon 3.06GHz, ServerWorks Chipset, 16 Intel E100
chips (82559ER)): =20

The corruption of the data payload of ICMP packets being forwarded!

This corruption happens to about 1% of all traffic, and only happens
when there's some PF_PACKET socket open (like tcpdump, nacctd, ...).

If you run tcpdump on the outbound interface of the firewall, the packet
payload is still intact.

This (production) system is running a custom 2.4.21 based kernel with
lots of current netfilter patch-o-matic patches.  However, the observed
corruption is present in all packets, even those who are not NAT'ed,
mangled or altered in any way.

However, the reproducible connection to PF_PACKET sockets leads my focus
a bit away from netfilter towards the core network stack.

Attached is a lsmod and lspci of that machine, as well as packet
captures taken via mirror port on the cisco switches on the inbound and
outbound interface for that packet.

Any clues, hints, ideas?  Has anyone ever observed something similar?


--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--FhKpTYimqQF2+bfE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=lspci
Content-Transfer-Encoding: quoted-printable

PCI devices found:
  Bus  0, device   0, function  0:
    Host bridge: ServerWorks CNB20-HE Host Bridge (rev 51).
  Bus  0, device   0, function  1:
    Host bridge: ServerWorks CNB20-HE Host Bridge (#2) (rev 0).
  Bus  0, device   0, function  2:
    Host bridge: ServerWorks CNB20-HE Host Bridge (#3) (rev 0).
  Bus  0, device   3, function  0:
    VGA compatible controller: ATI Technologies Inc Rage XL (rev 39).
      Master Capable.  Latency=3D64.  Min Gnt=3D8.
      Non-prefetchable 32 bit memory at 0xf6000000 [0xf6ffffff].
      I/O at 0x2400 [0x24ff].
      Non-prefetchable 32 bit memory at 0xf5ff0000 [0xf5ff0fff].
  Bus  0, device   4, function  0:
    System peripheral: PCI device 0e11:b203 (Compaq Computer Corporation) (=
rev 1).
      IRQ 5.
      I/O at 0x1800 [0x18ff].
      Non-prefetchable 32 bit memory at 0xf5fe0000 [0xf5fe01ff].
  Bus  0, device   4, function  2:
    System peripheral: PCI device 0e11:b204 (Compaq Computer Corporation) (=
rev 1).
      IRQ 10.
      Master Capable.  Latency=3D64. =20
      I/O at 0x2800 [0x28ff].
      Non-prefetchable 32 bit memory at 0xf5fd0000 [0xf5fd07ff].
      Non-prefetchable 32 bit memory at 0xf5fc0000 [0xf5fc1fff].
      Non-prefetchable 32 bit memory at 0xf5f00000 [0xf5f7ffff].
  Bus  0, device  15, function  0:
    ISA bridge: ServerWorks CSB5 South Bridge (rev 147).
      Master Capable.  Latency=3D32. =20
  Bus  0, device  15, function  1:
    IDE interface: ServerWorks CSB5 IDE Controller (rev 147).
      Master Capable.  Latency=3D64. =20
      I/O at 0x2000 [0x200f].
  Bus  0, device  15, function  2:
    USB Controller: ServerWorks OSB4/CSB5 OHCI USB Controller (rev 5).
      IRQ 11.
      Master Capable.  Latency=3D64.  Max Lat=3D80.
      Non-prefetchable 32 bit memory at 0xf5ef0000 [0xf5ef0fff].
  Bus  0, device  15, function  3:
    Host bridge: ServerWorks GCLE Host Bridge (rev 0).
  Bus  0, device  16, function  0:
    Host bridge: PCI device 1166:0101 (ServerWorks) (rev 5).
      Master Capable.  Latency=3D64. =20
  Bus  0, device  16, function  2:
    Host bridge: PCI device 1166:0101 (ServerWorks) (rev 5).
      Master Capable.  Latency=3D64. =20
  Bus  0, device  17, function  0:
    Host bridge: PCI device 1166:0101 (ServerWorks) (rev 5).
      Master Capable.  Latency=3D64. =20
  Bus  0, device  17, function  2:
    Host bridge: PCI device 1166:0101 (ServerWorks) (rev 5).
      Master Capable.  Latency=3D64. =20
  Bus  1, device   3, function  0:
    SCSI storage controller: Adaptec AHA-3960D / AIC-7899A U160/m (rev 1).
      IRQ 15.
      Master Capable.  Latency=3D64.  Min Gnt=3D40.Max Lat=3D25.
      I/O at 0x3000 [0x30ff].
      Non-prefetchable 64 bit memory at 0xf78f0000 [0xf78f0fff].
  Bus  1, device   3, function  1:
    SCSI storage controller: Adaptec AHA-3960D / AIC-7899A U160/m (#2) (rev=
 1).
      IRQ 15.
      Master Capable.  Latency=3D64.  Min Gnt=3D40.Max Lat=3D25.
      I/O at 0x3400 [0x34ff].
      Non-prefetchable 64 bit memory at 0xf78e0000 [0xf78e0fff].
  Bus  1, device   4, function  0:
    Ethernet controller: Broadcom Corporation NetXtreme BCM5703X Gigabit Et=
hernet (rev 2).
      IRQ 11.
      Master Capable.  Latency=3D64.  Min Gnt=3D64.
      Non-prefetchable 64 bit memory at 0xf78d0000 [0xf78dffff].
  Bus  2, device   1, function  0:
    PCI bridge: Intel Corp. 21152 PCI-to-PCI Bridge (rev 0).
      Master Capable.  Latency=3D64.  Min Gnt=3D7.
  Bus  2, device   2, function  0:
    PCI bridge: Intel Corp. 21152 PCI-to-PCI Bridge (#2) (rev 0).
      Master Capable.  Latency=3D64.  Min Gnt=3D7.
  Bus  6, device   1, function  0:
    PCI bridge: Intel Corp. 21152 PCI-to-PCI Bridge (#3) (rev 0).
      Master Capable.  Latency=3D64.  Min Gnt=3D7.
  Bus 10, device   1, function  0:
    PCI bridge: Intel Corp. 21152 PCI-to-PCI Bridge (#4) (rev 0).
      Master Capable.  Latency=3D64.  Min Gnt=3D7.
  Bus 10, device   2, function  0:
    PCI bridge: Intel Corp. 21152 PCI-to-PCI Bridge (#5) (rev 0).
      Master Capable.  Latency=3D64.  Min Gnt=3D7.
  Bus  3, device   0, function  0:
    Ethernet controller: Intel Corp. 82559ER (rev 9).
      IRQ 10.
      Master Capable.  Latency=3D64.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0xf79f0000 [0xf79f0fff].
      I/O at 0x4000 [0x403f].
      Non-prefetchable 32 bit memory at 0xf79c0000 [0xf79dffff].
  Bus  3, device   1, function  0:
    Ethernet controller: Intel Corp. 82559ER (#2) (rev 9).
      IRQ 5.
      Master Capable.  Latency=3D64.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0xf79b0000 [0xf79b0fff].
      I/O at 0x4040 [0x407f].
      Non-prefetchable 32 bit memory at 0xf7980000 [0xf799ffff].
  Bus  3, device   2, function  0:
    Ethernet controller: Intel Corp. 82559ER (#3) (rev 9).
      IRQ 10.
      Master Capable.  Latency=3D64.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0xf7970000 [0xf7970fff].
      I/O at 0x4080 [0x40bf].
      Non-prefetchable 32 bit memory at 0xf7940000 [0xf795ffff].
  Bus  4, device   0, function  0:
    Ethernet controller: Intel Corp. 82559ER (#4) (rev 9).
      IRQ 11.
      Master Capable.  Latency=3D64.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0xf7af0000 [0xf7af0fff].
      I/O at 0x5000 [0x503f].
      Non-prefetchable 32 bit memory at 0xf7ac0000 [0xf7adffff].
  Bus  4, device   1, function  0:
    Ethernet controller: Intel Corp. 82559ER (#5) (rev 9).
      IRQ 11.
      Master Capable.  Latency=3D64.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0xf7ab0000 [0xf7ab0fff].
      I/O at 0x5040 [0x507f].
      Non-prefetchable 32 bit memory at 0xf7a80000 [0xf7a9ffff].
  Bus  4, device   2, function  0:
    Ethernet controller: Intel Corp. 82559ER (#6) (rev 9).
      IRQ 11.
      Master Capable.  Latency=3D64.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0xf7a70000 [0xf7a70fff].
      I/O at 0x5080 [0x50bf].
      Non-prefetchable 32 bit memory at 0xf7a40000 [0xf7a5ffff].
  Bus  7, device   0, function  0:
    Ethernet controller: Intel Corp. 82559ER (#7) (rev 9).
      IRQ 11.
      Master Capable.  Latency=3D64.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0xf7df0000 [0xf7df0fff].
      I/O at 0x7000 [0x703f].
      Non-prefetchable 32 bit memory at 0xf7dc0000 [0xf7ddffff].
  Bus  7, device   1, function  0:
    Ethernet controller: Intel Corp. 82559ER (#8) (rev 9).
      IRQ 11.
      Master Capable.  Latency=3D64.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0xf7db0000 [0xf7db0fff].
      I/O at 0x7040 [0x707f].
      Non-prefetchable 32 bit memory at 0xf7d80000 [0xf7d9ffff].
  Bus  7, device   2, function  0:
    Ethernet controller: Intel Corp. 82559ER (#9) (rev 9).
      IRQ 11.
      Master Capable.  Latency=3D64.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0xf7d70000 [0xf7d70fff].
      I/O at 0x7080 [0x70bf].
      Non-prefetchable 32 bit memory at 0xf7d40000 [0xf7d5ffff].
  Bus 11, device   0, function  0:
    Ethernet controller: Intel Corp. 82559ER (#10) (rev 9).
      IRQ 11.
      Master Capable.  Latency=3D64.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0xf7ef0000 [0xf7ef0fff].
      I/O at 0x8000 [0x803f].
      Non-prefetchable 32 bit memory at 0xf7ec0000 [0xf7edffff].
  Bus 11, device   1, function  0:
    Ethernet controller: Intel Corp. 82559ER (#11) (rev 9).
      IRQ 11.
      Master Capable.  Latency=3D64.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0xf7eb0000 [0xf7eb0fff].
      I/O at 0x8040 [0x807f].
      Non-prefetchable 32 bit memory at 0xf7e80000 [0xf7e9ffff].
  Bus 11, device   2, function  0:
    Ethernet controller: Intel Corp. 82559ER (#12) (rev 9).
      IRQ 11.
      Master Capable.  Latency=3D64.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0xf7e70000 [0xf7e70fff].
      I/O at 0x8080 [0x80bf].
      Non-prefetchable 32 bit memory at 0xf7e40000 [0xf7e5ffff].
  Bus 12, device   0, function  0:
    Ethernet controller: Intel Corp. 82559ER (#13) (rev 9).
      IRQ 11.
      Master Capable.  Latency=3D64.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0xf7ff0000 [0xf7ff0fff].
      I/O at 0x9000 [0x903f].
      Non-prefetchable 32 bit memory at 0xf7fc0000 [0xf7fdffff].
  Bus 12, device   1, function  0:
    Ethernet controller: Intel Corp. 82559ER (#14) (rev 9).
      IRQ 11.
      Master Capable.  Latency=3D64.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0xf7fb0000 [0xf7fb0fff].
      I/O at 0x9040 [0x907f].
      Non-prefetchable 32 bit memory at 0xf7f80000 [0xf7f9ffff].
  Bus 12, device   2, function  0:
    Ethernet controller: Intel Corp. 82559ER (#15) (rev 9).
      IRQ 11.
      Master Capable.  Latency=3D64.  Min Gnt=3D8.Max Lat=3D56.
      Non-prefetchable 32 bit memory at 0xf7f70000 [0xf7f70fff].
      I/O at 0x9080 [0x90bf].
      Non-prefetchable 32 bit memory at 0xf7f40000 [0xf7f5ffff].
  Bus  3, device   3, function  0:
    Parallel controller: Oxford Semiconductor Ltd VScom 011H-EP1 1 port par=
allel adaptor (rev 0).
      IRQ 5.
      I/O at 0x40c0 [0x40c7].
      I/O at 0x40c8 [0x40cb].
      I/O at 0x40e0 [0x40ff].
      Non-prefetchable 32 bit memory at 0xf7930000 [0xf7930fff].
  Bus  4, device   3, function  0:
    Parallel controller: Oxford Semiconductor Ltd VScom 011H-EP1 1 port par=
allel adaptor (#2) (rev 0).
      IRQ 11.
      I/O at 0x50c0 [0x50c7].
      I/O at 0x50c8 [0x50cb].
      I/O at 0x50e0 [0x50ff].
      Non-prefetchable 32 bit memory at 0xf7a30000 [0xf7a30fff].
  Bus  7, device   3, function  0:
    Parallel controller: Oxford Semiconductor Ltd VScom 011H-EP1 1 port par=
allel adaptor (#3) (rev 0).
      IRQ 11.
      I/O at 0x70c0 [0x70c7].
      I/O at 0x70c8 [0x70cb].
      I/O at 0x70e0 [0x70ff].
      Non-prefetchable 32 bit memory at 0xf7d30000 [0xf7d30fff].
  Bus 11, device   3, function  0:
    Parallel controller: Oxford Semiconductor Ltd VScom 011H-EP1 1 port par=
allel adaptor (#4) (rev 0).
      IRQ 11.
      I/O at 0x80c0 [0x80c7].
      I/O at 0x80c8 [0x80cb].
      I/O at 0x80e0 [0x80ff].
      Non-prefetchable 32 bit memory at 0xf7e30000 [0xf7e30fff].
  Bus 12, device   3, function  0:
    Parallel controller: Oxford Semiconductor Ltd VScom 011H-EP1 1 port par=
allel adaptor (#5) (rev 0).
      IRQ 11.
      I/O at 0x90c0 [0x90c7].
      I/O at 0x90c8 [0x90cb].
      I/O at 0x90e0 [0x90ff].
      Non-prefetchable 32 bit memory at 0xf7f30000 [0xf7f30fff].
  Bus  6, device   2, function  0:
    RAID bus controller: Compaq Computer Corporation Smart Array 5i/532 (re=
v 1).
      IRQ 15.
      Master Capable.  Latency=3D71. =20
      Non-prefetchable 64 bit memory at 0xf7cc0000 [0xf7cfffff].
      I/O at 0x6000 [0x60ff].
      Prefetchable 64 bit memory at 0xf7bf0000 [0xf7bf3fff].

--FhKpTYimqQF2+bfE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=lsmod
Content-Transfer-Encoding: quoted-printable

Module                  Size  Used by    Not tainted
ipt_CLASSIFY             792   2  (autoclean)
ipt_tos                  472   1  (autoclean)
ipt_length               472   2  (autoclean)
ipt_MASQUERADE          1336   9  (autoclean)
ipt_dstlimit            7304   2  (autoclean)
ip_nat_mms              3056   0  (unused)
ip_nat_proto_gre        1316   0  (unused)
ip_nat_pptp             2348   0  (unused)
ip_nat_h323             2540   0  (unused)
ip_nat_irc              2288   0  (unused)
ip_nat_ftp              2864   0  (unused)
iptable_nat            16888   7  [ipt_MASQUERADE ip_nat_mms ip_nat_proto_g=
re ip_nat_pptp ip_nat_h323 ip_nat_irc ip_nat_ftp]
iptable_mangle          2072   1=20
ip_conntrack_mms        3344   1=20
ip_conntrack_pptp       2936   1=20
ip_conntrack_proto_gre    2720   0  [ip_nat_pptp ip_conntrack_pptp]
ip_conntrack_h323       2680   1=20
ip_conntrack_irc        3792   1=20
ip_conntrack_ftp        4592   1=20
nfnetlink_conntrack     8376   0  (unused)
nfnetlink               2540   1  [nfnetlink_conntrack]
ipt_owner               1272  23=20
ipt_REJECT              3224   1=20
ipt_LOG                 3904   9=20
ipt_unclean             6808   0  (unused)
pcmcia_core            42336   0=20
ipt_state                600   3  (autoclean)
ipt_NOTRACK              696   2  (autoclean)
iptable_raw             1200   1  (autoclean)
af_packet              12360   0=20
ip_conntrack           25132   8  [ipt_MASQUERADE ip_nat_mms ip_nat_pptp ip=
_nat_h323 ip_nat_irc ip_nat_ftp iptable_nat ip_conntrack_mms ip_conntrack_p=
ptp ip_conntrack_proto_gre ip_conntrack_h323 ip_conntrack_irc ip_conntrack_=
ftp nfnetlink_conntrack ipt_state ipt_NOTRACK]
iptable_filter          1644   1  (autoclean)
ip_tables              11936  17  [ipt_CLASSIFY ipt_tos ipt_length ipt_MASQ=
UERADE ipt_dstlimit iptable_nat iptable_mangle ipt_owner ipt_REJECT ipt_LOG=
 ipt_unclean ipt_state ipt_NOTRACK iptable_raw iptable_filter]
e100                   45156   7=20
bcm5700                76168   1=20
cciss                  27428   8=20
aic7xxx               160112   0=20
sd_mod                 12256   0  (unused)
scsi_mod               95084   2  [aic7xxx sd_mod]

--FhKpTYimqQF2+bfE
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="Output_01_fw_in.txt"
Content-Transfer-Encoding: quoted-printable

=0D
- - - - - - - - - - - - - - - - - - - - Frame 647 - - - - - - - - - - - - -=
 - - - - - - -=0D
 Frame Status Source                        Destination                   B=
ytes Rel Time     =0D
Delta Time   Abs time               Summary=0D
---------------------------------------------------------------------------=
---------------------------------------------------------------------------=
---------------=0D
   647        [172.18.64.1]                 [172.18.1.59]                  =
 414 0:00:00.975  =0D
0.000.828    05.04.2004 12:05:04 ICMP: Echo=0D
DLC:  ----- DLC Header -----=0D
      DLC:  =0D
      DLC:  Frame 647 arrived at  11:05:04.9495; frame size is 414 (019E he=
x) bytes.=0D
      DLC:  Destination =3D Station 000E7F2E9C96=0D
      DLC:  Source      =3D Station Cisco 82B084=0D
      DLC:  Ethertype   =3D 0800 (IP)=0D
      DLC:  =0D
IP: ----- IP Header -----=0D
      IP: =0D
      IP: Version =3D 4, header length =3D 20 bytes=0D
      IP: Type of service =3D 00=0D
      IP:       000. ....   =3D routine=0D
      IP:       ...0 .... =3D normal delay=0D
      IP:       .... 0... =3D normal throughput=0D
      IP:       .... .0.. =3D normal reliability=0D
      IP:       .... ..0. =3D ECT bit - transport protocol will ignore the =
CE bit=0D
      IP:       .... ...0 =3D CE bit - no congestion=0D
      IP: Total length    =3D 400 bytes=0D
      IP: Identification  =3D 31828=0D
      IP: Flags           =3D 0X=0D
      IP:       .0.. .... =3D may fragment=0D
      IP:       ..0. .... =3D last fragment=0D
      IP: Fragment offset =3D 0 bytes=0D
      IP: Time to live    =3D 255 seconds/hops=0D
      IP: Protocol        =3D 1 (ICMP)=0D
      IP: Header checksum =3D A4B7 (correct)=0D
      IP: Source address      =3D [172.18.64.1]=0D
      IP: Destination address =3D [172.18.1.59]=0D
      IP: No options=0D
      IP: =0D
ICMP: ----- ICMP header -----=0D
      ICMP: =0D
      ICMP: Type =3D 8 (Echo)=0D
      ICMP: Code =3D 0=0D
      ICMP: Checksum =3D E262 (correct)=0D
      ICMP: Identifier =3D 3494=0D
      ICMP: Sequence number =3D 1511=0D
      ICMP: [372 bytes of data]=0D
      ICMP: =0D
      ICMP: [Normal end of "ICMP header".]=0D
      ICMP: =0D
ADDR  HEX                                               ASCII=0D
0000: 00 0e 7f 2e 9c 96 00 b0 8e 82 b0 84 08 00 45 00 | ..=7F.=9C=96.=B0=8E=
=82=B0=84..E.=0D
0010: 01 90 7c 54 00 00 ff 01 a4 b7 ac 12 40 01 ac 12 | .=90|T..=FF.=A4=B7=
=AC.@.=AC.=0D
0020: 01 3b 08 00 e2 62 0d a6 05 e7 00 00 00 00 24 cf | .;..=E2b.=A6.=E7...=
=2E$=CF=0D
0030: b9 08 ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =B9.=AB=CD=AB=CD=AB=
=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0040: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0050: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0060: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0070: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0080: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0090: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00a0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00b0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00c0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00d0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00e0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00f0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0100: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0110: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0120: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0130: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0140: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0150: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0160: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0170: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0180: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0190: ab cd ab cd ab cd ab cd ab cd ab cd ab cd       | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=0D
=0D
- - - - - - - - - - - - - - - - - - - - Frame 648 - - - - - - - - - - - - -=
 - - - - - - -=0D
 Frame Status Source                        Destination                   B=
ytes Rel Time     =0D
Delta Time   Abs time               Summary=0D
---------------------------------------------------------------------------=
---------------------------------------------------------------------------=
---------------=0D
   648        [172.18.1.59]                 [172.18.64.1]                  =
 414 0:00:00.978  =0D
0.002.597    05.04.2004 12:05:04 ICMP: Echo reply=0D
DLC:  ----- DLC Header -----=0D
      DLC:  =0D
      DLC:  Frame 648 arrived at  11:05:04.9521; frame size is 414 (019E he=
x) bytes.=0D
      DLC:  Destination =3D Station Cisco 82B084=0D
      DLC:  Source      =3D Station 000E7F2E9C96=0D
      DLC:  Ethertype   =3D 0800 (IP)=0D
      DLC:  =0D
IP: ----- IP Header -----=0D
      IP: =0D
      IP: Version =3D 4, header length =3D 20 bytes=0D
      IP: Type of service =3D 00=0D
      IP:       000. ....   =3D routine=0D
      IP:       ...0 .... =3D normal delay=0D
      IP:       .... 0... =3D normal throughput=0D
      IP:       .... .0.. =3D normal reliability=0D
      IP:       .... ..0. =3D ECT bit - transport protocol will ignore the =
CE bit=0D
      IP:       .... ...0 =3D CE bit - no congestion=0D
      IP: Total length    =3D 400 bytes=0D
      IP: Identification  =3D 31828=0D
      IP: Flags           =3D 0X=0D
      IP:       .0.. .... =3D may fragment=0D
      IP:       ..0. .... =3D last fragment=0D
      IP: Fragment offset =3D 0 bytes=0D
      IP: Time to live    =3D 254 seconds/hops=0D
      IP: Protocol        =3D 1 (ICMP)=0D
      IP: Header checksum =3D A5B7 (correct)=0D
      IP: Source address      =3D [172.18.1.59]=0D
      IP: Destination address =3D [172.18.64.1]=0D
      IP: No options=0D
      IP: =0D
ICMP: ----- ICMP header -----=0D
      ICMP: =0D
      ICMP: Type =3D 0 (Echo reply)=0D
      ICMP: Code =3D 0=0D
      ICMP: Checksum =3D EA62 (correct)=0D
      ICMP: Identifier =3D 3494=0D
      ICMP: Sequence number =3D 1511=0D
      ICMP: [372 bytes of data]=0D
      ICMP: =0D
      ICMP: [Normal end of "ICMP header".]=0D
      ICMP: =0D
ADDR  HEX                                               ASCII=0D
0000: 00 b0 8e 82 b0 84 00 0e 7f 2e 9c 96 08 00 45 00 | .=B0=8E=82=B0=84..=
=7F.=9C=96..E.=0D
0010: 01 90 7c 54 00 00 fe 01 a5 b7 ac 12 01 3b ac 12 | .=90|T..=FE.=A5=B7=
=AC..;=AC.=0D
0020: 40 01 00 00 ea 62 0d a6 05 e7 00 00 00 00 24 cf | @...=EAb.=A6.=E7...=
=2E$=CF=0D
0030: b9 08 ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =B9.=AB=CD=AB=CD=AB=
=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0040: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0050: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0060: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0070: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0080: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0090: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00a0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00b0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00c0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00d0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00e0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00f0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0100: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0110: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0120: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0130: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0140: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0150: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0160: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0170: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0180: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0190: ab cd ab cd ab cd ab cd ab cd ab cd ab cd       | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=0D
=0D
- - - - - - - - - - - - - - - - - - - - Frame 649 - - - - - - - - - - - - -=
 - - - - - - -=0D
 Frame Status Source                        Destination                   B=
ytes Rel Time     =0D
Delta Time   Abs time               Summary=0D
---------------------------------------------------------------------------=
---------------------------------------------------------------------------=
---------------=0D
   649        [172.18.64.1]                 [172.18.1.59]                  =
 414 0:00:00.979  =0D
0.000.894    05.04.2004 12:05:04 ICMP: Echo=0D
DLC:  ----- DLC Header -----=0D
      DLC:  =0D
      DLC:  Frame 649 arrived at  11:05:04.9530; frame size is 414 (019E he=
x) bytes.=0D
      DLC:  Destination =3D Station 000E7F2E9C96=0D
      DLC:  Source      =3D Station Cisco 82B084=0D
      DLC:  Ethertype   =3D 0800 (IP)=0D
      DLC:  =0D
IP: ----- IP Header -----=0D
      IP: =0D
      IP: Version =3D 4, header length =3D 20 bytes=0D
      IP: Type of service =3D 00=0D
      IP:       000. ....   =3D routine=0D
      IP:       ...0 .... =3D normal delay=0D
      IP:       .... 0... =3D normal throughput=0D
      IP:       .... .0.. =3D normal reliability=0D
      IP:       .... ..0. =3D ECT bit - transport protocol will ignore the =
CE bit=0D
      IP:       .... ...0 =3D CE bit - no congestion=0D
      IP: Total length    =3D 400 bytes=0D
      IP: Identification  =3D 31829=0D
      IP: Flags           =3D 0X=0D
      IP:       .0.. .... =3D may fragment=0D
      IP:       ..0. .... =3D last fragment=0D
      IP: Fragment offset =3D 0 bytes=0D
      IP: Time to live    =3D 255 seconds/hops=0D
      IP: Protocol        =3D 1 (ICMP)=0D
      IP: Header checksum =3D A4B6 (correct)=0D
      IP: Source address      =3D [172.18.64.1]=0D
      IP: Destination address =3D [172.18.1.59]=0D
      IP: No options=0D
      IP: =0D
ICMP: ----- ICMP header -----=0D
      ICMP: =0D
      ICMP: Type =3D 8 (Echo)=0D
      ICMP: Code =3D 0=0D
      ICMP: Checksum =3D E25D (correct)=0D
      ICMP: Identifier =3D 3495=0D
      ICMP: Sequence number =3D 1511=0D
      ICMP: [372 bytes of data]=0D
      ICMP: =0D
      ICMP: [Normal end of "ICMP header".]=0D
      ICMP: =0D
ADDR  HEX                                               ASCII=0D
0000: 00 0e 7f 2e 9c 96 00 b0 8e 82 b0 84 08 00 45 00 | ..=7F.=9C=96.=B0=8E=
=82=B0=84..E.=0D
0010: 01 90 7c 55 00 00 ff 01 a4 b6 ac 12 40 01 ac 12 | .=90|U..=FF.=A4=B6=
=AC.@.=AC.=0D
0020: 01 3b 08 00 e2 5d 0d a7 05 e7 00 00 00 00 24 cf | .;..=E2].=A7.=E7...=
=2E$=CF=0D
0030: b9 0c ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =B9.=AB=CD=AB=CD=AB=
=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0040: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0050: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0060: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0070: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0080: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0090: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00a0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00b0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00c0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00d0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00e0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00f0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0100: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0110: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0120: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0130: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0140: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0150: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0160: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0170: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0180: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0190: ab cd ab cd ab cd ab cd ab cd ab cd ab cd       | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=0D
=0D
- - - - - - - - - - - - - - - - - - - - Frame 650 - - - - - - - - - - - - -=
 - - - - - - -=0D
 Frame Status Source                        Destination                   B=
ytes Rel Time     =0D
Delta Time   Abs time               Summary=0D
---------------------------------------------------------------------------=
---------------------------------------------------------------------------=
---------------=0D
   650        [172.18.64.1]                 [172.18.1.59]                  =
 414 0:00:02.977  =0D
1.998.516    05.04.2004 12:05:06 ICMP: Echo=0D
DLC:  ----- DLC Header -----=0D
      DLC:  =0D
      DLC:  Frame 650 arrived at  11:05:06.9515; frame size is 414 (019E he=
x) bytes.=0D
      DLC:  Destination =3D Station 000E7F2E9C96=0D
      DLC:  Source      =3D Station Cisco 82B084=0D
      DLC:  Ethertype   =3D 0800 (IP)=0D
      DLC:  =0D
IP: ----- IP Header -----=0D
      IP: =0D
      IP: Version =3D 4, header length =3D 20 bytes=0D
      IP: Type of service =3D 00=0D
      IP:       000. ....   =3D routine=0D
      IP:       ...0 .... =3D normal delay=0D
      IP:       .... 0... =3D normal throughput=0D
      IP:       .... .0.. =3D normal reliability=0D
      IP:       .... ..0. =3D ECT bit - transport protocol will ignore the =
CE bit=0D
      IP:       .... ...0 =3D CE bit - no congestion=0D
      IP: Total length    =3D 400 bytes=0D
      IP: Identification  =3D 31830=0D
      IP: Flags           =3D 0X=0D
      IP:       .0.. .... =3D may fragment=0D
      IP:       ..0. .... =3D last fragment=0D
      IP: Fragment offset =3D 0 bytes=0D
      IP: Time to live    =3D 255 seconds/hops=0D
      IP: Protocol        =3D 1 (ICMP)=0D
      IP: Header checksum =3D A4B5 (correct)=0D
      IP: Source address      =3D [172.18.64.1]=0D
      IP: Destination address =3D [172.18.1.59]=0D
      IP: No options=0D
      IP: =0D
ICMP: ----- ICMP header -----=0D
      ICMP: =0D
      ICMP: Type =3D 8 (Echo)=0D
      ICMP: Code =3D 0=0D
      ICMP: Checksum =3D DA8C (correct)=0D
      ICMP: Identifier =3D 3496=0D
      ICMP: Sequence number =3D 1511=0D
      ICMP: [372 bytes of data]=0D
      ICMP: =0D
      ICMP: [Normal end of "ICMP header".]=0D
      ICMP: =0D
ADDR  HEX                                               ASCII=0D
0000: 00 0e 7f 2e 9c 96 00 b0 8e 82 b0 84 08 00 45 00 | ..=7F.=9C=96.=B0=8E=
=82=B0=84..E.=0D
0010: 01 90 7c 56 00 00 ff 01 a4 b5 ac 12 40 01 ac 12 | .=90|V..=FF.=A4=B5=
=AC.@.=AC.=0D
0020: 01 3b 08 00 da 8c 0d a8 05 e7 00 00 00 00 24 cf | .;..=DA=8C.=A8.=E7.=
=2E..$=CF=0D
0030: c0 dc ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =C0=DC=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0040: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0050: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0060: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0070: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0080: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0090: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00a0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00b0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00c0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00d0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00e0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
00f0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0100: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0110: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0120: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0130: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0140: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0150: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0160: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0170: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0180: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD=0D
0190: ab cd ab cd ab cd ab cd ab cd ab cd ab cd       | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=0D

--FhKpTYimqQF2+bfE
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="Output_01_fw_out.txt"
Content-Transfer-Encoding: quoted-printable


- - - - - - - - - - - - - - - - - - - - Frame 647 - - - - - - - - - - - - -=
 - - - - - - -
 Frame Status Source                        Destination                   B=
ytes Rel Time    =20
Delta Time   Abs time               Summary
---------------------------------------------------------------------------=
---------------------------------------------------------------------------=
---------------
   647        [172.18.64.1]                 [172.18.1.59]                  =
 414 0:00:00.975 =20
0.001.070    05.04.2004 12:05:03 ICMP: Echo
DLC:  ----- DLC Header -----
      DLC: =20
      DLC:  Frame 647 arrived at  11:05:03.1245; frame size is 414 (019E he=
x) bytes.
      DLC:  Destination =3D Station Cisco 36CA88
      DLC:  Source      =3D Station IEEE  20E55D
      DLC:  Ethertype   =3D 0800 (IP)
      DLC: =20
IP: ----- IP Header -----
      IP:=20
      IP: Version =3D 4, header length =3D 20 bytes
      IP: Type of service =3D 00
      IP:       000. ....   =3D routine
      IP:       ...0 .... =3D normal delay
      IP:       .... 0... =3D normal throughput
      IP:       .... .0.. =3D normal reliability
      IP:       .... ..0. =3D ECT bit - transport protocol will ignore the =
CE bit
      IP:       .... ...0 =3D CE bit - no congestion
      IP: Total length    =3D 400 bytes
      IP: Identification  =3D 31828
      IP: Flags           =3D 0X
      IP:       .0.. .... =3D may fragment
      IP:       ..0. .... =3D last fragment
      IP: Fragment offset =3D 0 bytes
      IP: Time to live    =3D 254 seconds/hops
      IP: Protocol        =3D 1 (ICMP)
      IP: Header checksum =3D A5B7 (correct)
      IP: Source address      =3D [172.18.64.1]
      IP: Destination address =3D [172.18.1.59]
      IP: No options
      IP:=20
ICMP: ----- ICMP header -----
      ICMP:=20
      ICMP: Type =3D 8 (Echo)
      ICMP: Code =3D 0
      ICMP: Checksum =3D E262 (correct)
      ICMP: Identifier =3D 3494
      ICMP: Sequence number =3D 1511
      ICMP: [372 bytes of data]
      ICMP:=20
      ICMP: [Normal end of "ICMP header".]
      ICMP:=20
ADDR  HEX                                               ASCII
0000: 00 00 0c 36 ca 88 00 50 c2 20 e5 5d 08 00 45 00 | ...6=CA=88.P=C2 =E5=
]..E.
0010: 01 90 7c 54 00 00 fe 01 a5 b7 ac 12 40 01 ac 12 | .=90|T..=FE.=A5=B7=
=AC.@.=AC.
0020: 01 3b 08 00 e2 62 0d a6 05 e7 00 00 00 00 24 cf | .;..=E2b.=A6.=E7...=
=2E$=CF
0030: b9 08 ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =B9.=AB=CD=AB=CD=AB=
=CD=AB=CD=AB=CD=AB=CD=AB=CD
0040: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0050: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0060: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0070: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0080: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0090: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00a0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00b0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00c0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00d0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00e0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00f0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0100: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0110: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0120: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0130: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0140: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0150: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0160: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0170: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0180: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0190: ab cd ab cd ab cd ab cd ab cd ab cd ab cd       | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD

- - - - - - - - - - - - - - - - - - - - Frame 648 - - - - - - - - - - - - -=
 - - - - - - -
 Frame Status Source                        Destination                   B=
ytes Rel Time    =20
Delta Time   Abs time               Summary
---------------------------------------------------------------------------=
---------------------------------------------------------------------------=
---------------
   648        [172.18.1.59]                 [172.18.64.1]                  =
 414 0:00:00.976 =20
0.001.178    05.04.2004 12:05:03 ICMP: Echo reply
DLC:  ----- DLC Header -----
      DLC: =20
      DLC:  Frame 648 arrived at  11:05:03.1257; frame size is 414 (019E he=
x) bytes.
      DLC:  Destination =3D Station IEEE  20E55D
      DLC:  Source      =3D Station Cisco 36CA88
      DLC:  Ethertype   =3D 0800 (IP)
      DLC: =20
IP: ----- IP Header -----
      IP:=20
      IP: Version =3D 4, header length =3D 20 bytes
      IP: Type of service =3D 00
      IP:       000. ....   =3D routine
      IP:       ...0 .... =3D normal delay
      IP:       .... 0... =3D normal throughput
      IP:       .... .0.. =3D normal reliability
      IP:       .... ..0. =3D ECT bit - transport protocol will ignore the =
CE bit
      IP:       .... ...0 =3D CE bit - no congestion
      IP: Total length    =3D 400 bytes
      IP: Identification  =3D 31828
      IP: Flags           =3D 0X
      IP:       .0.. .... =3D may fragment
      IP:       ..0. .... =3D last fragment
      IP: Fragment offset =3D 0 bytes
      IP: Time to live    =3D 255 seconds/hops
      IP: Protocol        =3D 1 (ICMP)
      IP: Header checksum =3D A4B7 (correct)
      IP: Source address      =3D [172.18.1.59]
      IP: Destination address =3D [172.18.64.1]
      IP: No options
      IP:=20
ICMP: ----- ICMP header -----
      ICMP:=20
      ICMP: Type =3D 0 (Echo reply)
      ICMP: Code =3D 0
      ICMP: Checksum =3D EA62 (correct)
      ICMP: Identifier =3D 3494
      ICMP: Sequence number =3D 1511
      ICMP: [372 bytes of data]
      ICMP:=20
      ICMP: [Normal end of "ICMP header".]
      ICMP:=20
ADDR  HEX                                               ASCII
0000: 00 50 c2 20 e5 5d 00 00 0c 36 ca 88 08 00 45 00 | .P=C2 =E5]...6=CA=
=88..E.
0010: 01 90 7c 54 00 00 ff 01 a4 b7 ac 12 01 3b ac 12 | .=90|T..=FF.=A4=B7=
=AC..;=AC.
0020: 40 01 00 00 ea 62 0d a6 05 e7 00 00 00 00 24 cf | @...=EAb.=A6.=E7...=
=2E$=CF
0030: b9 08 ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =B9.=AB=CD=AB=CD=AB=
=CD=AB=CD=AB=CD=AB=CD=AB=CD
0040: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0050: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0060: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0070: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0080: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0090: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00a0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00b0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00c0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00d0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00e0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00f0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0100: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0110: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0120: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0130: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0140: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0150: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0160: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0170: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0180: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0190: ab cd ab cd ab cd ab cd ab cd ab cd ab cd       | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD

- - - - - - - - - - - - - - - - - - - - Frame 649 - - - - - - - - - - - - -=
 - - - - - - -
 Frame Status Source                        Destination                   B=
ytes Rel Time    =20
Delta Time   Abs time               Summary
---------------------------------------------------------------------------=
---------------------------------------------------------------------------=
---------------
   649        [172.18.64.1]                 [172.18.1.59]                  =
 414 0:00:00.979 =20
0.002.309    05.04.2004 12:05:03 ICMP: Echo
DLC:  ----- DLC Header -----
      DLC: =20
      DLC:  Frame 649 arrived at  11:05:03.1280; frame size is 414 (019E he=
x) bytes.
      DLC:  Destination =3D Station Cisco 36CA88
      DLC:  Source      =3D Station IEEE  20E55D
      DLC:  Ethertype   =3D 0800 (IP)
      DLC: =20
IP: ----- IP Header -----
      IP:=20
      IP: Version =3D 4, header length =3D 20 bytes
      IP: Type of service =3D 00
      IP:       000. ....   =3D routine
      IP:       ...0 .... =3D normal delay
      IP:       .... 0... =3D normal throughput
      IP:       .... .0.. =3D normal reliability
      IP:       .... ..0. =3D ECT bit - transport protocol will ignore the =
CE bit
      IP:       .... ...0 =3D CE bit - no congestion
      IP: Total length    =3D 400 bytes
      IP: Identification  =3D 31829
      IP: Flags           =3D 0X
      IP:       .0.. .... =3D may fragment
      IP:       ..0. .... =3D last fragment
      IP: Fragment offset =3D 0 bytes
      IP: Time to live    =3D 254 seconds/hops
      IP: Protocol        =3D 1 (ICMP)
      IP: Header checksum =3D A5B6 (correct)
      IP: Source address      =3D [172.18.64.1]
      IP: Destination address =3D [172.18.1.59]
      IP: No options
      IP:=20
ICMP: ----- ICMP header -----
      ICMP:=20
      ICMP: Type =3D 8 (Echo)
      ICMP: Code =3D 0
      ICMP: Checksum =3D E25D (should be FD10)
      ICMP: Identifier =3D 3495
      ICMP: Sequence number =3D 1511
      ICMP: [372 bytes of data]
      ICMP:=20
      ICMP: [Normal end of "ICMP header".]
      ICMP:=20
ADDR  HEX                                               ASCII
0000: 00 00 0c 36 ca 88 00 50 c2 20 e5 5d 08 00 45 00 | ...6=CA=88.P=C2 =E5=
]..E.
0010: 01 90 7c 55 00 00 fe 01 a5 b6 ac 12 40 01 ac 12 | .=90|U..=FE.=A5=B6=
=AC.@.=AC.
0020: 01 3b 08 00 e2 5d 0d a7 05 e7 00 00 00 00 24 cf | .;..=E2].=A7.=E7...=
=2E$=CF
0030: b9 0c ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =B9.=AB=CD=AB=CD=AB=
=CD=AB=CD=AB=CD=AB=CD=AB=CD
0040: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0050: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0060: ab cd ab cd ab cd ab cd ab cd ab cd ab cd 2b 06 | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD+.
0070: 01 02 01 02 02 01 07 32 05 00 36 12 f2 9b 00 54 | .......2..6.=F2=9B.T
0080: 00 48 00 54 00 02 00 26 00 07 40 59 00 00 5c 00 | .H.T...&..@Y..\.
0090: 50 00 49 00 50 00 45 00 5c 00 00 00 00 00 05 00 | P.I.P.E.\.......
00a0: 0b 00 10 00 00 00 48 00 00 00 04 00 00 00 30 16 | ......H.......0.
00b0: 30 16 00 00 00 00 01 00 00 00 00 00 01 00 78 57 | 0.............xW
00c0: 34 12 34 12 cd ab ef 00 01 23 45 67 89 ab 00 00 | 4.4.=CD=AB=EF..#Eg=
=89=AB..
00d0: 00 00 04 5d 88 8a eb 1c c9 11 9f e8 08 00 2b 10 | ...]=88=8A=EB.=C9.=
=9F=E8..+.
00e0: 48 60 02 00 00 00 74 61 62 6c 65 20 77 69 ab cd | H`....table wi=AB=CD
00f0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0100: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0110: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0120: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0130: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0140: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0150: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0160: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0170: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0180: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0190: ab cd ab cd ab cd ab cd ab cd ab cd ab cd       | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD

- - - - - - - - - - - - - - - - - - - - Frame 650 - - - - - - - - - - - - -=
 - - - - - - -
 Frame Status Source                        Destination                   B=
ytes Rel Time    =20
Delta Time   Abs time               Summary
---------------------------------------------------------------------------=
---------------------------------------------------------------------------=
---------------
   650        [172.18.64.1]                 [172.18.1.59]                  =
 414 0:00:02.977 =20
1.998.555    05.04.2004 12:05:05 ICMP: Echo
DLC:  ----- DLC Header -----
      DLC: =20
      DLC:  Frame 650 arrived at  11:05:05.1266; frame size is 414 (019E he=
x) bytes.
      DLC:  Destination =3D Station Cisco 36CA88
      DLC:  Source      =3D Station IEEE  20E55D
      DLC:  Ethertype   =3D 0800 (IP)
      DLC: =20
IP: ----- IP Header -----
      IP:=20
      IP: Version =3D 4, header length =3D 20 bytes
      IP: Type of service =3D 00
      IP:       000. ....   =3D routine
      IP:       ...0 .... =3D normal delay
      IP:       .... 0... =3D normal throughput
      IP:       .... .0.. =3D normal reliability
      IP:       .... ..0. =3D ECT bit - transport protocol will ignore the =
CE bit
      IP:       .... ...0 =3D CE bit - no congestion
      IP: Total length    =3D 400 bytes
      IP: Identification  =3D 31830
      IP: Flags           =3D 0X
      IP:       .0.. .... =3D may fragment
      IP:       ..0. .... =3D last fragment
      IP: Fragment offset =3D 0 bytes
      IP: Time to live    =3D 254 seconds/hops
      IP: Protocol        =3D 1 (ICMP)
      IP: Header checksum =3D A5B5 (correct)
      IP: Source address      =3D [172.18.64.1]
      IP: Destination address =3D [172.18.1.59]
      IP: No options
      IP:=20
ICMP: ----- ICMP header -----
      ICMP:=20
      ICMP: Type =3D 8 (Echo)
      ICMP: Code =3D 0
      ICMP: Checksum =3D DA8C (correct)
      ICMP: Identifier =3D 3496
      ICMP: Sequence number =3D 1511
      ICMP: [372 bytes of data]
      ICMP:=20
      ICMP: [Normal end of "ICMP header".]
      ICMP:=20
ADDR  HEX                                               ASCII
0000: 00 00 0c 36 ca 88 00 50 c2 20 e5 5d 08 00 45 00 | ...6=CA=88.P=C2 =E5=
]..E.
0010: 01 90 7c 56 00 00 fe 01 a5 b5 ac 12 40 01 ac 12 | .=90|V..=FE.=A5=B5=
=AC.@.=AC.
0020: 01 3b 08 00 da 8c 0d a8 05 e7 00 00 00 00 24 cf | .;..=DA=8C.=A8.=E7.=
=2E..$=CF
0030: c0 dc ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =C0=DC=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0040: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0050: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0060: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0070: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0080: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0090: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00a0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00b0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00c0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00d0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00e0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
00f0: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0100: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0110: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0120: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0130: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0140: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0150: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0160: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0170: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0180: ab cd ab cd ab cd ab cd ab cd ab cd ab cd ab cd | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD=AB=CD
0190: ab cd ab cd ab cd ab cd ab cd ab cd ab cd       | =AB=CD=AB=CD=AB=CD=
=AB=CD=AB=CD=AB=CD=AB=CD

--FhKpTYimqQF2+bfE--

--tzZdJ4yHDV5r1Akt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA6ps2XaXGVTD0i/8RArpiAJ9dpOUuJ/7VXeTDkHecI/hkCM/IYgCgkrMD
b/PQVY3LusGSdT3Vrzpplng=
=wfbb
-----END PGP SIGNATURE-----

--tzZdJ4yHDV5r1Akt--
