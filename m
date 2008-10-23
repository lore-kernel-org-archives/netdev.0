From: Sanjoy Mahajan <sanjoy@MIT.EDU>
Subject: Re: e1000e fails after several S3 resumes (2.6.26 Debian, TP T60)
Date: Thu, 23 Oct 2008 09:26:29 -0400
Message-ID: <E1Kt0Cr-0008PB-Ux@approx.mit.edu>
References: <4807377b0810220929v5906b42bgf9d63215370e5ab5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="----- =_aaaaaaaaaa0"
Cc: linux-kernel@vger.kernel.org,
	"NetDEV list" <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net
To: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from BISCAYNE-ONE-STATION.MIT.EDU ([18.7.7.80]:58286 "EHLO
	biscayne-one-station.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751571AbYJWNb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 09:31:58 -0400
In-Reply-To: Your message of "Wed, 22 Oct 2008 09:29:21 PDT."
             <4807377b0810220929v5906b42bgf9d63215370e5ab5@mail.gmail.com> (sfid-20081022_141704_643135_AA4BDC9C)
Content-ID: <32310.1224768389.0@approx.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------- =_aaaaaaaaaa0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <32310.1224768389.1@approx.mit.edu>

> There is also lots of opportunity for BIOS bugs to be effecting things
> so please make sure that you have the latest bios.

I was about to burn the CD to update the bios to 2.23 when the failure
recurred.  So, with the caveat that the bios is still 2.20, I've
attached logs from ethregs and ethtool before and after 
  ethtool -r eth0
(which fixed the dhcp).

Here is the e1000e driver version:

  $ grep e1000e /var/log/dmesg
  [   23.988317] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
  [   23.988390] e1000e: Copyright (c) 1999-2008 Intel Corporation.
  [   23.988505] e1000e 0000:02:00.0: Disabling L1 ASPM

Here are diffs of the attached before and after logs:

--- ethtool-before.log	2008-10-23 09:14:41.000000000 -0400
+++ ethtool-after.log	2008-10-23 09:17:54.000000000 -0400
@@ -33,8 +33,8 @@
       Pass MAC control frames:           don't pass
       Receive buffer size:               2048
 0x02808: RDLEN (Receive desc length)     0x00001000
-0x02810: RDH   (Receive desc head)       0x000000BB
-0x02818: RDT   (Receive desc tail)       0x000000B9
+0x02810: RDH   (Receive desc head)       0x00000051
+0x02818: RDT   (Receive desc tail)       0x0000004F
 0x02820: RDTR  (Receive delay timer)     0x00000000
 0x00400: TCTL (Transmit ctrl register)   0x3103F0FA
       Transmitter:                       enabled
@@ -42,7 +42,7 @@
       Software XOFF Transmission:        disabled
       Re-transmit on late collision:     enabled
 0x03808: TDLEN (Transmit desc length)    0x00001000
-0x03810: TDH   (Transmit desc head)      0x00000018
-0x03818: TDT   (Transmit desc tail)      0x00000018
+0x03810: TDH   (Transmit desc head)      0x00000075
+0x03818: TDT   (Transmit desc tail)      0x00000075
 0x03820: TIDV  (Transmit delay timer)    0x00000008
 PHY type:                                IGP2

--- ethregs-before.log	2008-10-23 09:13:50.000000000 -0400
+++ ethregs-after.log	2008-10-23 09:17:38.000000000 -0400
@@ -40,11 +40,11 @@
 	FCRTL          800047f8
 	FCRTH          00004800
 	PSRCTL         00040402
-	RDBAL          37c84000
+	RDBAL          37dde000
 	RDBAH          00000000
 	RDLEN          00001000
-	RDH            000000bf
-	RDT            000000bd
+	RDH            000000e3
+	RDT            000000e1
 	RDTR           00000000
 	RXDCTL         00010000
 	RADV           00000008
@@ -56,16 +56,16 @@
 	RSRPD          00000000
 	RAID           00000000
 	CPUVEC         00000000
-	TDFH           00000d14
-	TDFT           00000d14
-	TDFHS          00000d14
-	TDFTS          00000d14
+	TDFH           00000f96
+	TDFT           00000f96
+	TDFHS          00000f96
+	TDFTS          00000f96
 	TDFPC          00000000
-	TDBAL          2f30a000
+	TDBAL          377ed000
 	TDBAH          00000000
 	TDLEN          00001000
-	TDH            00000018
-	TDT            00000018
+	TDH            00000075
+	TDT            00000075
 	TIDV           00000008
 	TXDCTL         01410000
 	TADV           00000020
@@ -217,16 +217,16 @@
 	MTA[127]       00000000
 	RAL[0]         52411600
 	RAH[0]         8000de50
-	RAL[1]         00003333
+	RAL[1]         005e0001
 	RAH[1]         8000fb00
-	RAL[2]         52ff3333
-	RAH[2]         8000de50
-	RAL[3]         00003333
-	RAH[3]         80000100
-	RAL[4]         005e0001
+	RAL[2]         00003333
+	RAH[2]         8000fb00
+	RAL[3]         52ff3333
+	RAH[3]         8000de50
+	RAL[4]         00003333
 	RAH[4]         80000100
-	RAL[5]         00000000
-	RAH[5]         00000000
+	RAL[5]         005e0001
+	RAH[5]         80000100
 	RAL[6]         00000000
 	RAH[6]         00000000
 	RAL[7]         00000000
@@ -390,7 +390,7 @@
 	GSCL_2         00000000
 	GSCL_3         00000000
 	GSCL_4         00000000
-	FACTPS         a1041046
+	FACTPS         21041046
 	FWSM           00000000
 	RETA[0]        00000017
 	RETA[1]        000000e9


------- =_aaaaaaaaaa0
Content-Type: text/plain; name="ethregs-before.log"; charset="us-ascii"
Content-ID: <32310.1224768389.2@approx.mit.edu>
Content-Description: ethregs before

02:00.0 (8086:109a)
Intel Corporation 82573L Gigabit Ethernet Controller
	Name           Value
	~~~~           ~~~~~
	CTRL           18140248
	STATUS         80080783
	EECD           06008318
	EERD           ffb20012
	CTRL_EXT       28580000
	FLA            00000600
	MDIC           182a7800
	FCAL           00c28001
	FCAH           00000100
	FCT            00008808
	VET            00008100
	ITR            000000c3
	ICS            00000000
	IMS            0000009d
	IMC            0000009d
	IAM            ffffffff
	RCTL           04008002
	FCTTV          00000680
	TCTL           3103f0fa
	TIPG           00602008
	AIT            00000000
	LEDCTL         000f8b02
	EXTCNF_CTRL    0014000a
	EXTCNF_SIZE    00000004
	PBA            000c0014
	PBS            00000020
	EEMNGCTL       80000000
	EEARBC         001d0290
	FLASHT         00000002
	EEWR           00000002
	FLSWCTL        c0000000
	FLSWDATA       00000000
	FLSWCNT        00000000
	FLOP           0004db00
	ERT            00000000
	FCRTL          800047f8
	FCRTH          00004800
	PSRCTL         00040402
	RDBAL          37c84000
	RDBAH          00000000
	RDLEN          00001000
	RDH            000000bf
	RDT            000000bd
	RDTR           00000000
	RXDCTL         00010000
	RADV           00000008
	RDBAL1         01000000
	RDBAH1         00000400
	RDLEN1         00000000
	RDH1           00000000
	RDT1           00000000
	RSRPD          00000000
	RAID           00000000
	CPUVEC         00000000
	TDFH           00000d14
	TDFT           00000d14
	TDFHS          00000d14
	TDFTS          00000d14
	TDFPC          00000000
	TDBAL          2f30a000
	TDBAH          00000000
	TDLEN          00001000
	TDH            00000018
	TDT            00000018
	TIDV           00000008
	TXDCTL         01410000
	TADV           00000020
	TARC0          00000403
	TDBAL1         00000000
	TDBAH1         00000000
	TDLEN1         00000000
	TDH1           00000000
	TDT1           00000000
	TXDCTL1        00400000
	TARC1          00000403
	ICRXPTC        00000000
	ICRXATC        00000000
	ICTXPTC        00000000
	ICTXATC        00000000
	ICTXQEC        00000000
	ICTXQMTC       00000000
	ICRXDMTC       00000000
	ICRXOC         00000000
	RXCSUM         00000300
	RFCTL          00000000
	MTA[0]         00000000
	MTA[1]         00000000
	MTA[2]         00000000
	MTA[3]         00000000
	MTA[4]         00000000
	MTA[5]         00000000
	MTA[6]         00000000
	MTA[7]         00000000
	MTA[8]         00000000
	MTA[9]         00000000
	MTA[10]        00000000
	MTA[11]        00000000
	MTA[12]        00000000
	MTA[13]        00000000
	MTA[14]        00000000
	MTA[15]        00000000
	MTA[16]        00000000
	MTA[17]        00000000
	MTA[18]        00000000
	MTA[19]        00000000
	MTA[20]        00000000
	MTA[21]        00000000
	MTA[22]        00000000
	MTA[23]        00000000
	MTA[24]        00000000
	MTA[25]        00000000
	MTA[26]        00000000
	MTA[27]        00000000
	MTA[28]        00000000
	MTA[29]        00000000
	MTA[30]        00000000
	MTA[31]        00000000
	MTA[32]        00000000
	MTA[33]        00000000
	MTA[34]        00000000
	MTA[35]        00000000
	MTA[36]        00000000
	MTA[37]        00000000
	MTA[38]        00000000
	MTA[39]        00000000
	MTA[40]        00000000
	MTA[41]        00000000
	MTA[42]        00000000
	MTA[43]        00000000
	MTA[44]        00000000
	MTA[45]        00000000
	MTA[46]        00000000
	MTA[47]        00000000
	MTA[48]        00000000
	MTA[49]        00000000
	MTA[50]        00000000
	MTA[51]        00000000
	MTA[52]        00000000
	MTA[53]        00000000
	MTA[54]        00000000
	MTA[55]        00000000
	MTA[56]        00000000
	MTA[57]        00000000
	MTA[58]        00000000
	MTA[59]        00000000
	MTA[60]        00000000
	MTA[61]        00000000
	MTA[62]        00000000
	MTA[63]        00000000
	MTA[64]        00000000
	MTA[65]        00000000
	MTA[66]        00000000
	MTA[67]        00000000
	MTA[68]        00000000
	MTA[69]        00000000
	MTA[70]        00000000
	MTA[71]        00000000
	MTA[72]        00000000
	MTA[73]        00000000
	MTA[74]        00000000
	MTA[75]        00000000
	MTA[76]        00000000
	MTA[77]        00000000
	MTA[78]        00000000
	MTA[79]        00000000
	MTA[80]        00000000
	MTA[81]        00000000
	MTA[82]        00000000
	MTA[83]        00000000
	MTA[84]        00000000
	MTA[85]        00000000
	MTA[86]        00000000
	MTA[87]        00000000
	MTA[88]        00000000
	MTA[89]        00000000
	MTA[90]        00000000
	MTA[91]        00000000
	MTA[92]        00000000
	MTA[93]        00000000
	MTA[94]        00000000
	MTA[95]        00000000
	MTA[96]        00000000
	MTA[97]        00000000
	MTA[98]        00000000
	MTA[99]        00000000
	MTA[100]       00000000
	MTA[101]       00000000
	MTA[102]       00000000
	MTA[103]       00000000
	MTA[104]       00000000
	MTA[105]       00000000
	MTA[106]       00000000
	MTA[107]       00000000
	MTA[108]       00000000
	MTA[109]       00000000
	MTA[110]       00000000
	MTA[111]       00000000
	MTA[112]       00000000
	MTA[113]       00000000
	MTA[114]       00000000
	MTA[115]       00000000
	MTA[116]       00000000
	MTA[117]       00000000
	MTA[118]       00000000
	MTA[119]       00000000
	MTA[120]       00000000
	MTA[121]       00000000
	MTA[122]       00000000
	MTA[123]       00000000
	MTA[124]       00000000
	MTA[125]       00000000
	MTA[126]       00000000
	MTA[127]       00000000
	RAL[0]         52411600
	RAH[0]         8000de50
	RAL[1]         00003333
	RAH[1]         8000fb00
	RAL[2]         52ff3333
	RAH[2]         8000de50
	RAL[3]         00003333
	RAH[3]         80000100
	RAL[4]         005e0001
	RAH[4]         80000100
	RAL[5]         00000000
	RAH[5]         00000000
	RAL[6]         00000000
	RAH[6]         00000000
	RAL[7]         00000000
	RAH[7]         00000000
	RAL[8]         00000000
	RAH[8]         00000000
	RAL[9]         00000000
	RAH[9]         00000000
	RAL[10]        00000000
	RAH[10]        00000000
	RAL[11]        00000000
	RAH[11]        00000000
	RAL[12]        00000000
	RAH[12]        00000000
	RAL[13]        00000000
	RAH[13]        00000000
	RAL[14]        00000000
	RAH[14]        00000000
	RAL[15]        00000000
	RAH[15]        00000000
	VFTA[0]        00000000
	VFTA[1]        00000000
	VFTA[2]        00000000
	VFTA[3]        00000000
	VFTA[4]        00000000
	VFTA[5]        00000000
	VFTA[6]        00000000
	VFTA[7]        00000000
	VFTA[8]        00000000
	VFTA[9]        00000000
	VFTA[10]       00000000
	VFTA[11]       00000000
	VFTA[12]       00000000
	VFTA[13]       00000000
	VFTA[14]       00000000
	VFTA[15]       00000000
	VFTA[16]       00000000
	VFTA[17]       00000000
	VFTA[18]       00000000
	VFTA[19]       00000000
	VFTA[20]       00000000
	VFTA[21]       00000000
	VFTA[22]       00000000
	VFTA[23]       00000000
	VFTA[24]       00000000
	VFTA[25]       00000000
	VFTA[26]       00000000
	VFTA[27]       00000000
	VFTA[28]       00000000
	VFTA[29]       00000000
	VFTA[30]       00000000
	VFTA[31]       00000000
	VFTA[32]       00000000
	VFTA[33]       00000000
	VFTA[34]       00000000
	VFTA[35]       00000000
	VFTA[36]       00000000
	VFTA[37]       00000000
	VFTA[38]       00000000
	VFTA[39]       00000000
	VFTA[40]       00000000
	VFTA[41]       00000000
	VFTA[42]       00000000
	VFTA[43]       00000000
	VFTA[44]       00000000
	VFTA[45]       00000000
	VFTA[46]       00000000
	VFTA[47]       00000000
	VFTA[48]       00000000
	VFTA[49]       00000000
	VFTA[50]       00000000
	VFTA[51]       00000000
	VFTA[52]       00000000
	VFTA[53]       00000000
	VFTA[54]       00000000
	VFTA[55]       00000000
	VFTA[56]       00000000
	VFTA[57]       00000000
	VFTA[58]       00000000
	VFTA[59]       00000000
	VFTA[60]       00000000
	VFTA[61]       00000000
	VFTA[62]       00000000
	VFTA[63]       00000000
	VFTA[64]       00000000
	VFTA[65]       00000000
	VFTA[66]       00000000
	VFTA[67]       00000000
	VFTA[68]       00000000
	VFTA[69]       00000000
	VFTA[70]       00000000
	VFTA[71]       00000000
	VFTA[72]       00000000
	VFTA[73]       00000000
	VFTA[74]       00000000
	VFTA[75]       00000000
	VFTA[76]       00000000
	VFTA[77]       00000000
	VFTA[78]       00000000
	VFTA[79]       00000000
	VFTA[80]       00000000
	VFTA[81]       00000000
	VFTA[82]       00000000
	VFTA[83]       00000000
	VFTA[84]       00000000
	VFTA[85]       00000000
	VFTA[86]       00000000
	VFTA[87]       00000000
	VFTA[88]       00000000
	VFTA[89]       00000000
	VFTA[90]       00000000
	VFTA[91]       00000000
	VFTA[92]       00000000
	VFTA[93]       00000000
	VFTA[94]       00000000
	VFTA[95]       00000000
	VFTA[96]       00000000
	VFTA[97]       00000000
	VFTA[98]       00000000
	VFTA[99]       00000000
	VFTA[100]      00000000
	VFTA[101]      00000000
	VFTA[102]      00000000
	VFTA[103]      00000000
	VFTA[104]      00000000
	VFTA[105]      00000000
	VFTA[106]      00000000
	VFTA[107]      00000000
	VFTA[108]      00000000
	VFTA[109]      00000000
	VFTA[110]      00000000
	VFTA[111]      00000000
	VFTA[112]      00000000
	VFTA[113]      00000000
	VFTA[114]      00000000
	VFTA[115]      00000000
	VFTA[116]      00000000
	VFTA[117]      00000000
	VFTA[118]      00000000
	VFTA[119]      00000000
	VFTA[120]      00000000
	VFTA[121]      00000000
	VFTA[122]      00000000
	VFTA[123]      00000000
	VFTA[124]      00000000
	VFTA[125]      00000000
	VFTA[126]      00000000
	VFTA[127]      00000000
	WUC            00000000
	WUFC           00000000
	WUS            00000000
	MRQC           00000000
	MANC           00000100
	IPAV           00000000
	MANC2H         00000000
	RSSIM          00000000
	RSSIR          00000000
	WUPL           2f37ea88
	GCR            0e000000
	GSCL_1         00000000
	GSCL_2         00000000
	GSCL_3         00000000
	GSCL_4         00000000
	FACTPS         a1041046
	FWSM           00000000
	RETA[0]        00000017
	RETA[1]        000000e9
	RETA[2]        000000db
	RETA[3]        0000004d
	RETA[4]        00000096
	RETA[5]        000000dc
	RETA[6]        00000043
	RETA[7]        0000008f
	RETA[8]        0000000e
	RETA[9]        00000084
	RETA[10]       000000d3
	RETA[11]       00000067
	RETA[12]       0000002e
	RETA[13]       00000071
	RETA[14]       000000bf
	RETA[15]       00000057
	RETA[16]       000000ae
	RETA[17]       000000c0
	RETA[18]       00000059
	RETA[19]       000000b7
	RETA[20]       00000026
	RETA[21]       00000041
	RETA[22]       00000051
	RETA[23]       000000e7
	RETA[24]       00000096
	RETA[25]       000000df
	RETA[26]       00000013
	RETA[27]       00000055
	RETA[28]       00000025
	RETA[29]       000000c3
	RETA[30]       000000db
	RETA[31]       00000097
	RETA[32]       0000000e
	RETA[33]       0000007c
	RETA[34]       000000b9
	RETA[35]       0000004a
	RETA[36]       0000004e
	RETA[37]       0000001c
	RETA[38]       00000037
	RETA[39]       00000044
	RETA[40]       000000c7
	RETA[41]       00000039
	RETA[42]       00000033
	RETA[43]       000000ee
	RETA[44]       0000000e
	RETA[45]       00000080
	RETA[46]       0000007b
	RETA[47]       00000057
	RETA[48]       0000003e
	RETA[49]       0000001d
	RETA[50]       00000045
	RETA[51]       000000dd
	RETA[52]       0000003f
	RETA[53]       00000079
	RETA[54]       0000007f
	RETA[55]       000000c0
	RETA[56]       00000006
	RETA[57]       0000001d
	RETA[58]       0000005f
	RETA[59]       0000009f
	RETA[60]       00000017
	RETA[61]       000000ed
	RETA[62]       00000043
	RETA[63]       000000e7
	RETA[64]       0000000f
	RETA[65]       0000002c
	RETA[66]       00000003
	RETA[67]       00000055
	RETA[68]       0000000f
	RETA[69]       000000bd
	RETA[70]       00000033
	RETA[71]       000000ff
	RETA[72]       0000008d
	RETA[73]       000000cd
	RETA[74]       00000073
	RETA[75]       00000067
	RETA[76]       00000047
	RETA[77]       000000ed
	RETA[78]       0000005b
	RETA[79]       00000037
	RETA[80]       0000008a
	RETA[81]       00000048
	RETA[82]       00000030
	RETA[83]       000000c6
	RETA[84]       0000009f
	RETA[85]       00000053
	RETA[86]       00000013
	RETA[87]       000000f4
	RETA[88]       000000c6
	RETA[89]       000000f5
	RETA[90]       0000006b
	RETA[91]       00000046
	RETA[92]       0000002b
	RETA[93]       0000006a
	RETA[94]       00000078
	RETA[95]       0000005f
	RETA[96]       00000087
	RETA[97]       000000c1
	RETA[98]       000000d3
	RETA[99]       000000c7
	RETA[100]      0000003e
	RETA[101]      00000046
	RETA[102]      0000001a
	RETA[103]      000000e0
	RETA[104]      0000008d
	RETA[105]      000000c9
	RETA[106]      00000059
	RETA[107]      00000075
	RETA[108]      000000cf
	RETA[109]      00000067
	RETA[110]      000000a6
	RETA[111]      0000004e
	RETA[112]      000000ad
	RETA[113]      0000006d
	RETA[114]      0000005f
	RETA[115]      0000006c
	RETA[116]      0000004a
	RETA[117]      0000009b
	RETA[118]      000000ce
	RETA[119]      000000c7
	RETA[120]      000000ce
	RETA[121]      00000074
	RETA[122]      00000093
	RETA[123]      000000d7
	RETA[124]      00000027
	RETA[125]      0000009a
	RETA[126]      000000e9
	RETA[127]      000000e6
	RSSRK[0]       00000000
	RSSRK[1]       00000000
	RSSRK[2]       00000000
	RSSRK[3]       00000000
	RSSRK[4]       00000000
	RSSRK[5]       00000000
	RSSRK[6]       00000000
	RSSRK[7]       00000000
	RSSRK[8]       00000000
	RSSRK[9]       00000000
	RSSRK[10]      00000000
	RSSRK[11]      00000000
	RSSRK[12]      00000000
	RSSRK[13]      00000000
	RSSRK[14]      00000000
	RSSRK[15]      00000000
	RSSRK[16]      00000000
	RSSRK[17]      00000000
	RSSRK[18]      00000000
	RSSRK[19]      00000000
	RSSRK[20]      00000000
	RSSRK[21]      00000000
	RSSRK[22]      00000000
	RSSRK[23]      00000000
	RSSRK[24]      00000000
	RSSRK[25]      00000000
	RSSRK[26]      00000000
	RSSRK[27]      00000000
	RSSRK[28]      00000000
	RSSRK[29]      00000000
	RSSRK[30]      00000000
	RSSRK[31]      00000000
	RSSRK[32]      00000000
	RSSRK[33]      00000000
	RSSRK[34]      00000000
	RSSRK[35]      00000000
	RSSRK[36]      00000000
	RSSRK[37]      00000000
	RSSRK[38]      00000000
	RSSRK[39]      00000000
	FFLT[0]        00000000
	FFLT[1]        fffc0000
	FFLT[2]        00000000
	FFLT[3]        00000000
	FFLT[4]        00000000
	FFLT[5]        00000000
	FFLT[6]        00000000
	FFLT[7]        00000000
	FFLT[8]        00000000
	FFLT[9]        00000000
	FFLT[10]       00000000
	FFLT[11]       00000000
	HICR           00000000
	FFMT[0]        00000001
	FFMT[1]        00000001
	FFMT[2]        0000000d
	FFMT[3]        0000000d
	FFMT[4]        0000000e
	FFMT[5]        0000000e
	FFMT[6]        00000004
	FFMT[7]        00000004
	FFMT[8]        0000000d
	FFMT[9]        0000000d
	FFMT[10]       0000000f
	FFMT[11]       0000000f
	FFMT[12]       0000000b
	FFMT[13]       0000000b
	FFMT[14]       00000005
	FFMT[15]       00000005
	FFMT[16]       00000005
	FFMT[17]       00000005
	FFMT[18]       00000000
	FFMT[19]       00000000
	FFMT[20]       00000006
	FFMT[21]       00000006
	FFMT[22]       00000001
	FFMT[23]       00000001
	FFMT[24]       00000009
	FFMT[25]       00000009
	FFMT[26]       00000006
	FFMT[27]       00000006
	FFMT[28]       00000009
	FFMT[29]       00000009
	FFMT[30]       0000000b
	FFMT[31]       0000000b
	FFMT[32]       0000000a
	FFMT[33]       0000000a
	FFMT[34]       0000000b
	FFMT[35]       0000000b
	FFMT[36]       00000008
	FFMT[37]       00000008
	FFMT[38]       00000003
	FFMT[39]       00000003
	FFMT[40]       00000004
	FFMT[41]       00000004
	FFMT[42]       00000003
	FFMT[43]       00000003
	FFMT[44]       00000005
	FFMT[45]       00000005
	FFMT[46]       0000000d
	FFMT[47]       0000000d
	FFMT[48]       00000002
	FFMT[49]       00000002
	FFMT[50]       0000000a
	FFMT[51]       0000000a
	FFMT[52]       00000008
	FFMT[53]       00000008
	FFMT[54]       00000000
	FFMT[55]       00000000
	FFMT[56]       0000000c
	FFMT[57]       0000000c
	FFMT[58]       0000000f
	FFMT[59]       0000000f
	FFMT[60]       00000001
	FFMT[61]       00000001
	FFMT[62]       00000005
	FFMT[63]       00000005
	FFMT[64]       0000000c
	FFMT[65]       0000000c
	FFMT[66]       0000000c
	FFMT[67]       0000000c
	FFMT[68]       00000005
	FFMT[69]       00000005
	FFMT[70]       00000006
	FFMT[71]       00000006
	FFMT[72]       0000000b
	FFMT[73]       0000000b
	FFMT[74]       00000003
	FFMT[75]       00000003
	FFMT[76]       0000000b
	FFMT[77]       0000000b
	FFMT[78]       0000000b
	FFMT[79]       0000000b
	FFMT[80]       00000006
	FFMT[81]       00000006
	FFMT[82]       00000004
	FFMT[83]       00000004
	FFMT[84]       00000003
	FFMT[85]       00000003
	FFMT[86]       00000000
	FFMT[87]       00000000
	FFMT[88]       0000000e
	FFMT[89]       0000000e
	FFMT[90]       0000000f
	FFMT[91]       0000000f
	FFMT[92]       0000000e
	FFMT[93]       0000000e
	FFMT[94]       00000008
	FFMT[95]       00000008
	FFMT[96]       00000006
	FFMT[97]       00000006
	FFMT[98]       00000006
	FFMT[99]       00000006
	FFMT[100]      00000006
	FFMT[101]      00000006
	FFMT[102]      0000000a
	FFMT[103]      0000000a
	FFMT[104]      00000006
	FFMT[105]      00000006
	FFMT[106]      0000000f
	FFMT[107]      0000000f
	FFMT[108]      00000006
	FFMT[109]      00000006
	FFMT[110]      00000001
	FFMT[111]      00000001
	FFMT[112]      0000000c
	FFMT[113]      0000000c
	FFMT[114]      00000000
	FFMT[115]      00000000
	FFMT[116]      0000000b
	FFMT[117]      0000000b
	FFMT[118]      00000008
	FFMT[119]      00000008
	FFMT[120]      00000000
	FFMT[121]      00000000
	FFMT[122]      0000000e
	FFMT[123]      0000000e
	FFMT[124]      00000001
	FFMT[125]      00000001
	FFMT[126]      00000004
	FFMT[127]      00000004
	FFVT[0]        23d88e7c
	FFVT[1]        23d88e7c
	FFVT[2]        1d3a297a
	FFVT[3]        1d3a297a
	FFVT[4]        51bc65ae
	FFVT[5]        51bc65ae
	FFVT[6]        da762895
	FFVT[7]        da762895
	FFVT[8]        5df890f2
	FFVT[9]        5df890f2
	FFVT[10]       b1b18faa
	FFVT[11]       b1b18faa
	FFVT[12]       034c6839
	FFVT[13]       034c6839
	FFVT[14]       84d2a7f7
	FFVT[15]       84d2a7f7
	FFVT[16]       2e103715
	FFVT[17]       2e103715
	FFVT[18]       9cfd9827
	FFVT[19]       9cfd9827
	FFVT[20]       c0694511
	FFVT[21]       c0694511
	FFVT[22]       501d23c2
	FFVT[23]       501d23c2
	FFVT[24]       cefe88e3
	FFVT[25]       cefe88e3
	FFVT[26]       280be31a
	FFVT[27]       280be31a
	FFVT[28]       0a4c0c95
	FFVT[29]       0a4c0c95
	FFVT[30]       1fc115fd
	FFVT[31]       1fc115fd
	FFVT[32]       c836047e
	FFVT[33]       c836047e
	FFVT[34]       e1c7dff2
	FFVT[35]       e1c7dff2
	FFVT[36]       6672d188
	FFVT[37]       6672d188
	FFVT[38]       01e38d12
	FFVT[39]       01e38d12
	FFVT[40]       a8178e35
	FFVT[41]       a8178e35
	FFVT[42]       31e181ad
	FFVT[43]       31e181ad
	FFVT[44]       8698d481
	FFVT[45]       8698d481
	FFVT[46]       e0ebe17c
	FFVT[47]       e0ebe17c
	FFVT[48]       2cc0a025
	FFVT[49]       2cc0a025
	FFVT[50]       3e667df0
	FFVT[51]       3e667df0
	FFVT[52]       e18f46a1
	FFVT[53]       e18f46a1
	FFVT[54]       5b754add
	FFVT[55]       5b754add
	FFVT[56]       a74c6bc6
	FFVT[57]       a74c6bc6
	FFVT[58]       316f7741
	FFVT[59]       316f7741
	FFVT[60]       1ac272fc
	FFVT[61]       1ac272fc
	FFVT[62]       2dfdc5d3
	FFVT[63]       2dfdc5d3
	FFVT[64]       87100ab8
	FFVT[65]       87100ab8
	FFVT[66]       d6fb2743
	FFVT[67]       d6fb2743
	FFVT[68]       f8a84cc4
	FFVT[69]       f8a84cc4
	FFVT[70]       ab015c0f
	FFVT[71]       ab015c0f
	FFVT[72]       bb011c76
	FFVT[73]       bb011c76
	FFVT[74]       65a1db16
	FFVT[75]       65a1db16
	FFVT[76]       1130a1e4
	FFVT[77]       1130a1e4
	FFVT[78]       8fa01192
	FFVT[79]       8fa01192
	FFVT[80]       05b0daa8
	FFVT[81]       05b0daa8
	FFVT[82]       6e727a5f
	FFVT[83]       6e727a5f
	FFVT[84]       70683900
	FFVT[85]       70683900
	FFVT[86]       80d721f0
	FFVT[87]       80d721f0
	FFVT[88]       28e79415
	FFVT[89]       28e79415
	FFVT[90]       0d81d4bb
	FFVT[91]       0d81d4bb
	FFVT[92]       76252834
	FFVT[93]       76252834
	FFVT[94]       1b6025cc
	FFVT[95]       1b6025cc
	FFVT[96]       480491a2
	FFVT[97]       480491a2
	FFVT[98]       3a894208
	FFVT[99]       3a894208
	FFVT[100]      72c2e372
	FFVT[101]      72c2e372
	FFVT[102]      33ffdbf8
	FFVT[103]      33ffdbf8
	FFVT[104]      ced0bc94
	FFVT[105]      ced0bc94
	FFVT[106]      1db644f8
	FFVT[107]      1db644f8
	FFVT[108]      0f9b2628
	FFVT[109]      0f9b2628
	FFVT[110]      c2e1fd34
	FFVT[111]      c2e1fd34
	FFVT[112]      72826d62
	FFVT[113]      72826d62
	FFVT[114]      9d493778
	FFVT[115]      9d493778
	FFVT[116]      33b2d204
	FFVT[117]      33b2d204
	FFVT[118]      c6421e2e
	FFVT[119]      c6421e2e
	FFVT[120]      f20c8743
	FFVT[121]      f20c8743
	FFVT[122]      f5f2dafd
	FFVT[123]      f5f2dafd
	FFVT[124]      c242c15b
	FFVT[125]      c242c15b
	FFVT[126]      2dc6130c
	FFVT[127]      2dc6130c



------- =_aaaaaaaaaa0
Content-Type: text/plain; name="ethregs-after.log"; charset="us-ascii"
Content-ID: <32310.1224768389.3@approx.mit.edu>
Content-Description: ethregs after

02:00.0 (8086:109a)
Intel Corporation 82573L Gigabit Ethernet Controller
	Name           Value
	~~~~           ~~~~~
	CTRL           18140248
	STATUS         80080783
	EECD           06008318
	EERD           ffb20012
	CTRL_EXT       28580000
	FLA            00000600
	MDIC           182a7800
	FCAL           00c28001
	FCAH           00000100
	FCT            00008808
	VET            00008100
	ITR            000000c3
	ICS            00000000
	IMS            0000009d
	IMC            0000009d
	IAM            ffffffff
	RCTL           04008002
	FCTTV          00000680
	TCTL           3103f0fa
	TIPG           00602008
	AIT            00000000
	LEDCTL         000f8b02
	EXTCNF_CTRL    0014000a
	EXTCNF_SIZE    00000004
	PBA            000c0014
	PBS            00000020
	EEMNGCTL       80000000
	EEARBC         001d0290
	FLASHT         00000002
	EEWR           00000002
	FLSWCTL        c0000000
	FLSWDATA       00000000
	FLSWCNT        00000000
	FLOP           0004db00
	ERT            00000000
	FCRTL          800047f8
	FCRTH          00004800
	PSRCTL         00040402
	RDBAL          37dde000
	RDBAH          00000000
	RDLEN          00001000
	RDH            000000e3
	RDT            000000e1
	RDTR           00000000
	RXDCTL         00010000
	RADV           00000008
	RDBAL1         01000000
	RDBAH1         00000400
	RDLEN1         00000000
	RDH1           00000000
	RDT1           00000000
	RSRPD          00000000
	RAID           00000000
	CPUVEC         00000000
	TDFH           00000f96
	TDFT           00000f96
	TDFHS          00000f96
	TDFTS          00000f96
	TDFPC          00000000
	TDBAL          377ed000
	TDBAH          00000000
	TDLEN          00001000
	TDH            00000075
	TDT            00000075
	TIDV           00000008
	TXDCTL         01410000
	TADV           00000020
	TARC0          00000403
	TDBAL1         00000000
	TDBAH1         00000000
	TDLEN1         00000000
	TDH1           00000000
	TDT1           00000000
	TXDCTL1        00400000
	TARC1          00000403
	ICRXPTC        00000000
	ICRXATC        00000000
	ICTXPTC        00000000
	ICTXATC        00000000
	ICTXQEC        00000000
	ICTXQMTC       00000000
	ICRXDMTC       00000000
	ICRXOC         00000000
	RXCSUM         00000300
	RFCTL          00000000
	MTA[0]         00000000
	MTA[1]         00000000
	MTA[2]         00000000
	MTA[3]         00000000
	MTA[4]         00000000
	MTA[5]         00000000
	MTA[6]         00000000
	MTA[7]         00000000
	MTA[8]         00000000
	MTA[9]         00000000
	MTA[10]        00000000
	MTA[11]        00000000
	MTA[12]        00000000
	MTA[13]        00000000
	MTA[14]        00000000
	MTA[15]        00000000
	MTA[16]        00000000
	MTA[17]        00000000
	MTA[18]        00000000
	MTA[19]        00000000
	MTA[20]        00000000
	MTA[21]        00000000
	MTA[22]        00000000
	MTA[23]        00000000
	MTA[24]        00000000
	MTA[25]        00000000
	MTA[26]        00000000
	MTA[27]        00000000
	MTA[28]        00000000
	MTA[29]        00000000
	MTA[30]        00000000
	MTA[31]        00000000
	MTA[32]        00000000
	MTA[33]        00000000
	MTA[34]        00000000
	MTA[35]        00000000
	MTA[36]        00000000
	MTA[37]        00000000
	MTA[38]        00000000
	MTA[39]        00000000
	MTA[40]        00000000
	MTA[41]        00000000
	MTA[42]        00000000
	MTA[43]        00000000
	MTA[44]        00000000
	MTA[45]        00000000
	MTA[46]        00000000
	MTA[47]        00000000
	MTA[48]        00000000
	MTA[49]        00000000
	MTA[50]        00000000
	MTA[51]        00000000
	MTA[52]        00000000
	MTA[53]        00000000
	MTA[54]        00000000
	MTA[55]        00000000
	MTA[56]        00000000
	MTA[57]        00000000
	MTA[58]        00000000
	MTA[59]        00000000
	MTA[60]        00000000
	MTA[61]        00000000
	MTA[62]        00000000
	MTA[63]        00000000
	MTA[64]        00000000
	MTA[65]        00000000
	MTA[66]        00000000
	MTA[67]        00000000
	MTA[68]        00000000
	MTA[69]        00000000
	MTA[70]        00000000
	MTA[71]        00000000
	MTA[72]        00000000
	MTA[73]        00000000
	MTA[74]        00000000
	MTA[75]        00000000
	MTA[76]        00000000
	MTA[77]        00000000
	MTA[78]        00000000
	MTA[79]        00000000
	MTA[80]        00000000
	MTA[81]        00000000
	MTA[82]        00000000
	MTA[83]        00000000
	MTA[84]        00000000
	MTA[85]        00000000
	MTA[86]        00000000
	MTA[87]        00000000
	MTA[88]        00000000
	MTA[89]        00000000
	MTA[90]        00000000
	MTA[91]        00000000
	MTA[92]        00000000
	MTA[93]        00000000
	MTA[94]        00000000
	MTA[95]        00000000
	MTA[96]        00000000
	MTA[97]        00000000
	MTA[98]        00000000
	MTA[99]        00000000
	MTA[100]       00000000
	MTA[101]       00000000
	MTA[102]       00000000
	MTA[103]       00000000
	MTA[104]       00000000
	MTA[105]       00000000
	MTA[106]       00000000
	MTA[107]       00000000
	MTA[108]       00000000
	MTA[109]       00000000
	MTA[110]       00000000
	MTA[111]       00000000
	MTA[112]       00000000
	MTA[113]       00000000
	MTA[114]       00000000
	MTA[115]       00000000
	MTA[116]       00000000
	MTA[117]       00000000
	MTA[118]       00000000
	MTA[119]       00000000
	MTA[120]       00000000
	MTA[121]       00000000
	MTA[122]       00000000
	MTA[123]       00000000
	MTA[124]       00000000
	MTA[125]       00000000
	MTA[126]       00000000
	MTA[127]       00000000
	RAL[0]         52411600
	RAH[0]         8000de50
	RAL[1]         005e0001
	RAH[1]         8000fb00
	RAL[2]         00003333
	RAH[2]         8000fb00
	RAL[3]         52ff3333
	RAH[3]         8000de50
	RAL[4]         00003333
	RAH[4]         80000100
	RAL[5]         005e0001
	RAH[5]         80000100
	RAL[6]         00000000
	RAH[6]         00000000
	RAL[7]         00000000
	RAH[7]         00000000
	RAL[8]         00000000
	RAH[8]         00000000
	RAL[9]         00000000
	RAH[9]         00000000
	RAL[10]        00000000
	RAH[10]        00000000
	RAL[11]        00000000
	RAH[11]        00000000
	RAL[12]        00000000
	RAH[12]        00000000
	RAL[13]        00000000
	RAH[13]        00000000
	RAL[14]        00000000
	RAH[14]        00000000
	RAL[15]        00000000
	RAH[15]        00000000
	VFTA[0]        00000000
	VFTA[1]        00000000
	VFTA[2]        00000000
	VFTA[3]        00000000
	VFTA[4]        00000000
	VFTA[5]        00000000
	VFTA[6]        00000000
	VFTA[7]        00000000
	VFTA[8]        00000000
	VFTA[9]        00000000
	VFTA[10]       00000000
	VFTA[11]       00000000
	VFTA[12]       00000000
	VFTA[13]       00000000
	VFTA[14]       00000000
	VFTA[15]       00000000
	VFTA[16]       00000000
	VFTA[17]       00000000
	VFTA[18]       00000000
	VFTA[19]       00000000
	VFTA[20]       00000000
	VFTA[21]       00000000
	VFTA[22]       00000000
	VFTA[23]       00000000
	VFTA[24]       00000000
	VFTA[25]       00000000
	VFTA[26]       00000000
	VFTA[27]       00000000
	VFTA[28]       00000000
	VFTA[29]       00000000
	VFTA[30]       00000000
	VFTA[31]       00000000
	VFTA[32]       00000000
	VFTA[33]       00000000
	VFTA[34]       00000000
	VFTA[35]       00000000
	VFTA[36]       00000000
	VFTA[37]       00000000
	VFTA[38]       00000000
	VFTA[39]       00000000
	VFTA[40]       00000000
	VFTA[41]       00000000
	VFTA[42]       00000000
	VFTA[43]       00000000
	VFTA[44]       00000000
	VFTA[45]       00000000
	VFTA[46]       00000000
	VFTA[47]       00000000
	VFTA[48]       00000000
	VFTA[49]       00000000
	VFTA[50]       00000000
	VFTA[51]       00000000
	VFTA[52]       00000000
	VFTA[53]       00000000
	VFTA[54]       00000000
	VFTA[55]       00000000
	VFTA[56]       00000000
	VFTA[57]       00000000
	VFTA[58]       00000000
	VFTA[59]       00000000
	VFTA[60]       00000000
	VFTA[61]       00000000
	VFTA[62]       00000000
	VFTA[63]       00000000
	VFTA[64]       00000000
	VFTA[65]       00000000
	VFTA[66]       00000000
	VFTA[67]       00000000
	VFTA[68]       00000000
	VFTA[69]       00000000
	VFTA[70]       00000000
	VFTA[71]       00000000
	VFTA[72]       00000000
	VFTA[73]       00000000
	VFTA[74]       00000000
	VFTA[75]       00000000
	VFTA[76]       00000000
	VFTA[77]       00000000
	VFTA[78]       00000000
	VFTA[79]       00000000
	VFTA[80]       00000000
	VFTA[81]       00000000
	VFTA[82]       00000000
	VFTA[83]       00000000
	VFTA[84]       00000000
	VFTA[85]       00000000
	VFTA[86]       00000000
	VFTA[87]       00000000
	VFTA[88]       00000000
	VFTA[89]       00000000
	VFTA[90]       00000000
	VFTA[91]       00000000
	VFTA[92]       00000000
	VFTA[93]       00000000
	VFTA[94]       00000000
	VFTA[95]       00000000
	VFTA[96]       00000000
	VFTA[97]       00000000
	VFTA[98]       00000000
	VFTA[99]       00000000
	VFTA[100]      00000000
	VFTA[101]      00000000
	VFTA[102]      00000000
	VFTA[103]      00000000
	VFTA[104]      00000000
	VFTA[105]      00000000
	VFTA[106]      00000000
	VFTA[107]      00000000
	VFTA[108]      00000000
	VFTA[109]      00000000
	VFTA[110]      00000000
	VFTA[111]      00000000
	VFTA[112]      00000000
	VFTA[113]      00000000
	VFTA[114]      00000000
	VFTA[115]      00000000
	VFTA[116]      00000000
	VFTA[117]      00000000
	VFTA[118]      00000000
	VFTA[119]      00000000
	VFTA[120]      00000000
	VFTA[121]      00000000
	VFTA[122]      00000000
	VFTA[123]      00000000
	VFTA[124]      00000000
	VFTA[125]      00000000
	VFTA[126]      00000000
	VFTA[127]      00000000
	WUC            00000000
	WUFC           00000000
	WUS            00000000
	MRQC           00000000
	MANC           00000100
	IPAV           00000000
	MANC2H         00000000
	RSSIM          00000000
	RSSIR          00000000
	WUPL           2f37ea88
	GCR            0e000000
	GSCL_1         00000000
	GSCL_2         00000000
	GSCL_3         00000000
	GSCL_4         00000000
	FACTPS         21041046
	FWSM           00000000
	RETA[0]        00000017
	RETA[1]        000000e9
	RETA[2]        000000db
	RETA[3]        0000004d
	RETA[4]        00000096
	RETA[5]        000000dc
	RETA[6]        00000043
	RETA[7]        0000008f
	RETA[8]        0000000e
	RETA[9]        00000084
	RETA[10]       000000d3
	RETA[11]       00000067
	RETA[12]       0000002e
	RETA[13]       00000071
	RETA[14]       000000bf
	RETA[15]       00000057
	RETA[16]       000000ae
	RETA[17]       000000c0
	RETA[18]       00000059
	RETA[19]       000000b7
	RETA[20]       00000026
	RETA[21]       00000041
	RETA[22]       00000051
	RETA[23]       000000e7
	RETA[24]       00000096
	RETA[25]       000000df
	RETA[26]       00000013
	RETA[27]       00000055
	RETA[28]       00000025
	RETA[29]       000000c3
	RETA[30]       000000db
	RETA[31]       00000097
	RETA[32]       0000000e
	RETA[33]       0000007c
	RETA[34]       000000b9
	RETA[35]       0000004a
	RETA[36]       0000004e
	RETA[37]       0000001c
	RETA[38]       00000037
	RETA[39]       00000044
	RETA[40]       000000c7
	RETA[41]       00000039
	RETA[42]       00000033
	RETA[43]       000000ee
	RETA[44]       0000000e
	RETA[45]       00000080
	RETA[46]       0000007b
	RETA[47]       00000057
	RETA[48]       0000003e
	RETA[49]       0000001d
	RETA[50]       00000045
	RETA[51]       000000dd
	RETA[52]       0000003f
	RETA[53]       00000079
	RETA[54]       0000007f
	RETA[55]       000000c0
	RETA[56]       00000006
	RETA[57]       0000001d
	RETA[58]       0000005f
	RETA[59]       0000009f
	RETA[60]       00000017
	RETA[61]       000000ed
	RETA[62]       00000043
	RETA[63]       000000e7
	RETA[64]       0000000f
	RETA[65]       0000002c
	RETA[66]       00000003
	RETA[67]       00000055
	RETA[68]       0000000f
	RETA[69]       000000bd
	RETA[70]       00000033
	RETA[71]       000000ff
	RETA[72]       0000008d
	RETA[73]       000000cd
	RETA[74]       00000073
	RETA[75]       00000067
	RETA[76]       00000047
	RETA[77]       000000ed
	RETA[78]       0000005b
	RETA[79]       00000037
	RETA[80]       0000008a
	RETA[81]       00000048
	RETA[82]       00000030
	RETA[83]       000000c6
	RETA[84]       0000009f
	RETA[85]       00000053
	RETA[86]       00000013
	RETA[87]       000000f4
	RETA[88]       000000c6
	RETA[89]       000000f5
	RETA[90]       0000006b
	RETA[91]       00000046
	RETA[92]       0000002b
	RETA[93]       0000006a
	RETA[94]       00000078
	RETA[95]       0000005f
	RETA[96]       00000087
	RETA[97]       000000c1
	RETA[98]       000000d3
	RETA[99]       000000c7
	RETA[100]      0000003e
	RETA[101]      00000046
	RETA[102]      0000001a
	RETA[103]      000000e0
	RETA[104]      0000008d
	RETA[105]      000000c9
	RETA[106]      00000059
	RETA[107]      00000075
	RETA[108]      000000cf
	RETA[109]      00000067
	RETA[110]      000000a6
	RETA[111]      0000004e
	RETA[112]      000000ad
	RETA[113]      0000006d
	RETA[114]      0000005f
	RETA[115]      0000006c
	RETA[116]      0000004a
	RETA[117]      0000009b
	RETA[118]      000000ce
	RETA[119]      000000c7
	RETA[120]      000000ce
	RETA[121]      00000074
	RETA[122]      00000093
	RETA[123]      000000d7
	RETA[124]      00000027
	RETA[125]      0000009a
	RETA[126]      000000e9
	RETA[127]      000000e6
	RSSRK[0]       00000000
	RSSRK[1]       00000000
	RSSRK[2]       00000000
	RSSRK[3]       00000000
	RSSRK[4]       00000000
	RSSRK[5]       00000000
	RSSRK[6]       00000000
	RSSRK[7]       00000000
	RSSRK[8]       00000000
	RSSRK[9]       00000000
	RSSRK[10]      00000000
	RSSRK[11]      00000000
	RSSRK[12]      00000000
	RSSRK[13]      00000000
	RSSRK[14]      00000000
	RSSRK[15]      00000000
	RSSRK[16]      00000000
	RSSRK[17]      00000000
	RSSRK[18]      00000000
	RSSRK[19]      00000000
	RSSRK[20]      00000000
	RSSRK[21]      00000000
	RSSRK[22]      00000000
	RSSRK[23]      00000000
	RSSRK[24]      00000000
	RSSRK[25]      00000000
	RSSRK[26]      00000000
	RSSRK[27]      00000000
	RSSRK[28]      00000000
	RSSRK[29]      00000000
	RSSRK[30]      00000000
	RSSRK[31]      00000000
	RSSRK[32]      00000000
	RSSRK[33]      00000000
	RSSRK[34]      00000000
	RSSRK[35]      00000000
	RSSRK[36]      00000000
	RSSRK[37]      00000000
	RSSRK[38]      00000000
	RSSRK[39]      00000000
	FFLT[0]        00000000
	FFLT[1]        fffc0000
	FFLT[2]        00000000
	FFLT[3]        00000000
	FFLT[4]        00000000
	FFLT[5]        00000000
	FFLT[6]        00000000
	FFLT[7]        00000000
	FFLT[8]        00000000
	FFLT[9]        00000000
	FFLT[10]       00000000
	FFLT[11]       00000000
	HICR           00000000
	FFMT[0]        00000001
	FFMT[1]        00000001
	FFMT[2]        0000000d
	FFMT[3]        0000000d
	FFMT[4]        0000000e
	FFMT[5]        0000000e
	FFMT[6]        00000004
	FFMT[7]        00000004
	FFMT[8]        0000000d
	FFMT[9]        0000000d
	FFMT[10]       0000000f
	FFMT[11]       0000000f
	FFMT[12]       0000000b
	FFMT[13]       0000000b
	FFMT[14]       00000005
	FFMT[15]       00000005
	FFMT[16]       00000005
	FFMT[17]       00000005
	FFMT[18]       00000000
	FFMT[19]       00000000
	FFMT[20]       00000006
	FFMT[21]       00000006
	FFMT[22]       00000001
	FFMT[23]       00000001
	FFMT[24]       00000009
	FFMT[25]       00000009
	FFMT[26]       00000006
	FFMT[27]       00000006
	FFMT[28]       00000009
	FFMT[29]       00000009
	FFMT[30]       0000000b
	FFMT[31]       0000000b
	FFMT[32]       0000000a
	FFMT[33]       0000000a
	FFMT[34]       0000000b
	FFMT[35]       0000000b
	FFMT[36]       00000008
	FFMT[37]       00000008
	FFMT[38]       00000003
	FFMT[39]       00000003
	FFMT[40]       00000004
	FFMT[41]       00000004
	FFMT[42]       00000003
	FFMT[43]       00000003
	FFMT[44]       00000005
	FFMT[45]       00000005
	FFMT[46]       0000000d
	FFMT[47]       0000000d
	FFMT[48]       00000002
	FFMT[49]       00000002
	FFMT[50]       0000000a
	FFMT[51]       0000000a
	FFMT[52]       00000008
	FFMT[53]       00000008
	FFMT[54]       00000000
	FFMT[55]       00000000
	FFMT[56]       0000000c
	FFMT[57]       0000000c
	FFMT[58]       0000000f
	FFMT[59]       0000000f
	FFMT[60]       00000001
	FFMT[61]       00000001
	FFMT[62]       00000005
	FFMT[63]       00000005
	FFMT[64]       0000000c
	FFMT[65]       0000000c
	FFMT[66]       0000000c
	FFMT[67]       0000000c
	FFMT[68]       00000005
	FFMT[69]       00000005
	FFMT[70]       00000006
	FFMT[71]       00000006
	FFMT[72]       0000000b
	FFMT[73]       0000000b
	FFMT[74]       00000003
	FFMT[75]       00000003
	FFMT[76]       0000000b
	FFMT[77]       0000000b
	FFMT[78]       0000000b
	FFMT[79]       0000000b
	FFMT[80]       00000006
	FFMT[81]       00000006
	FFMT[82]       00000004
	FFMT[83]       00000004
	FFMT[84]       00000003
	FFMT[85]       00000003
	FFMT[86]       00000000
	FFMT[87]       00000000
	FFMT[88]       0000000e
	FFMT[89]       0000000e
	FFMT[90]       0000000f
	FFMT[91]       0000000f
	FFMT[92]       0000000e
	FFMT[93]       0000000e
	FFMT[94]       00000008
	FFMT[95]       00000008
	FFMT[96]       00000006
	FFMT[97]       00000006
	FFMT[98]       00000006
	FFMT[99]       00000006
	FFMT[100]      00000006
	FFMT[101]      00000006
	FFMT[102]      0000000a
	FFMT[103]      0000000a
	FFMT[104]      00000006
	FFMT[105]      00000006
	FFMT[106]      0000000f
	FFMT[107]      0000000f
	FFMT[108]      00000006
	FFMT[109]      00000006
	FFMT[110]      00000001
	FFMT[111]      00000001
	FFMT[112]      0000000c
	FFMT[113]      0000000c
	FFMT[114]      00000000
	FFMT[115]      00000000
	FFMT[116]      0000000b
	FFMT[117]      0000000b
	FFMT[118]      00000008
	FFMT[119]      00000008
	FFMT[120]      00000000
	FFMT[121]      00000000
	FFMT[122]      0000000e
	FFMT[123]      0000000e
	FFMT[124]      00000001
	FFMT[125]      00000001
	FFMT[126]      00000004
	FFMT[127]      00000004
	FFVT[0]        23d88e7c
	FFVT[1]        23d88e7c
	FFVT[2]        1d3a297a
	FFVT[3]        1d3a297a
	FFVT[4]        51bc65ae
	FFVT[5]        51bc65ae
	FFVT[6]        da762895
	FFVT[7]        da762895
	FFVT[8]        5df890f2
	FFVT[9]        5df890f2
	FFVT[10]       b1b18faa
	FFVT[11]       b1b18faa
	FFVT[12]       034c6839
	FFVT[13]       034c6839
	FFVT[14]       84d2a7f7
	FFVT[15]       84d2a7f7
	FFVT[16]       2e103715
	FFVT[17]       2e103715
	FFVT[18]       9cfd9827
	FFVT[19]       9cfd9827
	FFVT[20]       c0694511
	FFVT[21]       c0694511
	FFVT[22]       501d23c2
	FFVT[23]       501d23c2
	FFVT[24]       cefe88e3
	FFVT[25]       cefe88e3
	FFVT[26]       280be31a
	FFVT[27]       280be31a
	FFVT[28]       0a4c0c95
	FFVT[29]       0a4c0c95
	FFVT[30]       1fc115fd
	FFVT[31]       1fc115fd
	FFVT[32]       c836047e
	FFVT[33]       c836047e
	FFVT[34]       e1c7dff2
	FFVT[35]       e1c7dff2
	FFVT[36]       6672d188
	FFVT[37]       6672d188
	FFVT[38]       01e38d12
	FFVT[39]       01e38d12
	FFVT[40]       a8178e35
	FFVT[41]       a8178e35
	FFVT[42]       31e181ad
	FFVT[43]       31e181ad
	FFVT[44]       8698d481
	FFVT[45]       8698d481
	FFVT[46]       e0ebe17c
	FFVT[47]       e0ebe17c
	FFVT[48]       2cc0a025
	FFVT[49]       2cc0a025
	FFVT[50]       3e667df0
	FFVT[51]       3e667df0
	FFVT[52]       e18f46a1
	FFVT[53]       e18f46a1
	FFVT[54]       5b754add
	FFVT[55]       5b754add
	FFVT[56]       a74c6bc6
	FFVT[57]       a74c6bc6
	FFVT[58]       316f7741
	FFVT[59]       316f7741
	FFVT[60]       1ac272fc
	FFVT[61]       1ac272fc
	FFVT[62]       2dfdc5d3
	FFVT[63]       2dfdc5d3
	FFVT[64]       87100ab8
	FFVT[65]       87100ab8
	FFVT[66]       d6fb2743
	FFVT[67]       d6fb2743
	FFVT[68]       f8a84cc4
	FFVT[69]       f8a84cc4
	FFVT[70]       ab015c0f
	FFVT[71]       ab015c0f
	FFVT[72]       bb011c76
	FFVT[73]       bb011c76
	FFVT[74]       65a1db16
	FFVT[75]       65a1db16
	FFVT[76]       1130a1e4
	FFVT[77]       1130a1e4
	FFVT[78]       8fa01192
	FFVT[79]       8fa01192
	FFVT[80]       05b0daa8
	FFVT[81]       05b0daa8
	FFVT[82]       6e727a5f
	FFVT[83]       6e727a5f
	FFVT[84]       70683900
	FFVT[85]       70683900
	FFVT[86]       80d721f0
	FFVT[87]       80d721f0
	FFVT[88]       28e79415
	FFVT[89]       28e79415
	FFVT[90]       0d81d4bb
	FFVT[91]       0d81d4bb
	FFVT[92]       76252834
	FFVT[93]       76252834
	FFVT[94]       1b6025cc
	FFVT[95]       1b6025cc
	FFVT[96]       480491a2
	FFVT[97]       480491a2
	FFVT[98]       3a894208
	FFVT[99]       3a894208
	FFVT[100]      72c2e372
	FFVT[101]      72c2e372
	FFVT[102]      33ffdbf8
	FFVT[103]      33ffdbf8
	FFVT[104]      ced0bc94
	FFVT[105]      ced0bc94
	FFVT[106]      1db644f8
	FFVT[107]      1db644f8
	FFVT[108]      0f9b2628
	FFVT[109]      0f9b2628
	FFVT[110]      c2e1fd34
	FFVT[111]      c2e1fd34
	FFVT[112]      72826d62
	FFVT[113]      72826d62
	FFVT[114]      9d493778
	FFVT[115]      9d493778
	FFVT[116]      33b2d204
	FFVT[117]      33b2d204
	FFVT[118]      c6421e2e
	FFVT[119]      c6421e2e
	FFVT[120]      f20c8743
	FFVT[121]      f20c8743
	FFVT[122]      f5f2dafd
	FFVT[123]      f5f2dafd
	FFVT[124]      c242c15b
	FFVT[125]      c242c15b
	FFVT[126]      2dc6130c
	FFVT[127]      2dc6130c



------- =_aaaaaaaaaa0
Content-Type: text/plain; name="ethtool-before.log"; charset="us-ascii"
Content-ID: <32310.1224768389.4@approx.mit.edu>
Content-Description: ethtool before

MAC Registers
-------------
0x00000: CTRL (Device control register)  0x18140248
      Endian mode (buffers):             little
      Link reset:                        reset
      Set link up:                       1
      Invert Loss-Of-Signal:             no
      Receive flow control:              enabled
      Transmit flow control:             enabled
      VLAN mode:                         disabled
      Auto speed detect:                 disabled
      Speed select:                      1000Mb/s
      Force speed:                       no
      Force duplex:                      no
0x00008: STATUS (Device status register) 0x80080783
      Duplex:                            full
      Link up:                           link config
      TBI mode:                          disabled
      Link speed:                        1000Mb/s
      Bus type:                          PCI Express
      Port number:                       0
0x00100: RCTL (Receive control register) 0x04008002
      Receiver:                          enabled
      Store bad packets:                 disabled
      Unicast promiscuous:               disabled
      Multicast promiscuous:             disabled
      Long packet:                       disabled
      Descriptor minimum threshold size: 1/2
      Broadcast accept mode:             accept
      VLAN filter:                       disabled
      Canonical form indicator:          disabled
      Discard pause frames:              filtered
      Pass MAC control frames:           don't pass
      Receive buffer size:               2048
0x02808: RDLEN (Receive desc length)     0x00001000
0x02810: RDH   (Receive desc head)       0x000000BB
0x02818: RDT   (Receive desc tail)       0x000000B9
0x02820: RDTR  (Receive delay timer)     0x00000000
0x00400: TCTL (Transmit ctrl register)   0x3103F0FA
      Transmitter:                       enabled
      Pad short packets:                 enabled
      Software XOFF Transmission:        disabled
      Re-transmit on late collision:     enabled
0x03808: TDLEN (Transmit desc length)    0x00001000
0x03810: TDH   (Transmit desc head)      0x00000018
0x03818: TDT   (Transmit desc tail)      0x00000018
0x03820: TIDV  (Transmit delay timer)    0x00000008
PHY type:                                IGP2

------- =_aaaaaaaaaa0
Content-Type: text/plain; name="ethtool-after.log"; charset="us-ascii"
Content-ID: <32310.1224768389.5@approx.mit.edu>
Content-Description: ethtool after

MAC Registers
-------------
0x00000: CTRL (Device control register)  0x18140248
      Endian mode (buffers):             little
      Link reset:                        reset
      Set link up:                       1
      Invert Loss-Of-Signal:             no
      Receive flow control:              enabled
      Transmit flow control:             enabled
      VLAN mode:                         disabled
      Auto speed detect:                 disabled
      Speed select:                      1000Mb/s
      Force speed:                       no
      Force duplex:                      no
0x00008: STATUS (Device status register) 0x80080783
      Duplex:                            full
      Link up:                           link config
      TBI mode:                          disabled
      Link speed:                        1000Mb/s
      Bus type:                          PCI Express
      Port number:                       0
0x00100: RCTL (Receive control register) 0x04008002
      Receiver:                          enabled
      Store bad packets:                 disabled
      Unicast promiscuous:               disabled
      Multicast promiscuous:             disabled
      Long packet:                       disabled
      Descriptor minimum threshold size: 1/2
      Broadcast accept mode:             accept
      VLAN filter:                       disabled
      Canonical form indicator:          disabled
      Discard pause frames:              filtered
      Pass MAC control frames:           don't pass
      Receive buffer size:               2048
0x02808: RDLEN (Receive desc length)     0x00001000
0x02810: RDH   (Receive desc head)       0x00000051
0x02818: RDT   (Receive desc tail)       0x0000004F
0x02820: RDTR  (Receive delay timer)     0x00000000
0x00400: TCTL (Transmit ctrl register)   0x3103F0FA
      Transmitter:                       enabled
      Pad short packets:                 enabled
      Software XOFF Transmission:        disabled
      Re-transmit on late collision:     enabled
0x03808: TDLEN (Transmit desc length)    0x00001000
0x03810: TDH   (Transmit desc head)      0x00000075
0x03818: TDT   (Transmit desc tail)      0x00000075
0x03820: TIDV  (Transmit delay timer)    0x00000008
PHY type:                                IGP2

------- =_aaaaaaaaaa0--
