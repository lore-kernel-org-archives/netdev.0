From: Juerg Haefliger <juerg.haefliger@hpe.com>
Subject: Re: [PATCH RFC 0/4] xfs: Transmit flow steering
Date: Fri, 7 Oct 2016 11:18:35 +0200
Message-ID: <768e3ac5-0951-26c2-699e-1c2c8a1f431c@hpe.com>
References: <1472601634-531498-1-git-send-email-tom@herbertland.com>
 <7c278b6b-085c-e77c-ed77-0150e1718e7f@hpe.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="g7xRMMu7xdX8OULrnpHiou6Tm5xjvcARH"
Cc: kernel-team@fb.com, "Balliet, Drew" <andrew_balliet@hpe.com>
To: Rick Jones <rick.jones2@hpe.com>,
        Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hpe.com ([15.241.32.99]:12381 "EHLO
        g9t1613g.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751779AbcJGJS7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 05:18:59 -0400
Received: from g2t2354.austin.hpe.com (g2t2354.austin.hpe.com [15.233.44.27])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g9t1613g.houston.hpe.com (Postfix) with ESMTPS id 93EC467E5D
        for <netdev@vger.kernel.org>; Fri,  7 Oct 2016 09:18:57 +0000 (UTC)
In-Reply-To: <7c278b6b-085c-e77c-ed77-0150e1718e7f@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--g7xRMMu7xdX8OULrnpHiou6Tm5xjvcARH
Content-Type: multipart/mixed; boundary="RqOvSlOHVWWcEUq14Hgcrm5bnEVxNJ14A";
 protected-headers="v1"
From: Juerg Haefliger <juerg.haefliger@hpe.com>
To: Rick Jones <rick.jones2@hpe.com>, Tom Herbert <tom@herbertland.com>,
 davem@davemloft.net, netdev@vger.kernel.org
Cc: kernel-team@fb.com, "Balliet, Drew" <andrew_balliet@hpe.com>
Message-ID: <768e3ac5-0951-26c2-699e-1c2c8a1f431c@hpe.com>
Subject: Re: [PATCH RFC 0/4] xfs: Transmit flow steering
References: <1472601634-531498-1-git-send-email-tom@herbertland.com>
 <7c278b6b-085c-e77c-ed77-0150e1718e7f@hpe.com>
In-Reply-To: <7c278b6b-085c-e77c-ed77-0150e1718e7f@hpe.com>

--RqOvSlOHVWWcEUq14Hgcrm5bnEVxNJ14A
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

As Rick states, this fixes a performance issue with the 4.4 kernel for us=
=2E

Tested-by: Juerg Haefliger <juerg.haefliger@hpe.com>


On 09/28/2016 05:13 PM, Rick Jones wrote:
>=20
> Here is a quick look at performance tests for the result of trying the
> prototype fix for the packet reordering problem with VMs sending over
> an XPS-configured NIC.  In particular, the Emulex/Avago/Broadcom
> Skyhawk.  The fix was applied to a 4.4 kernel.
>=20
> Before: 3884 Mbit/s
> After: 8897 Mbit/s
>=20
> That was from a VM on a node with a Skyhawk and 2 E5-2640 processors
> to baremetal E5-2640 with a BE3.  Physical MTU was 1500, the VM's
> vNIC's MTU was 1400.  Systems were HPE ProLiants in OS Control Mode
> for power management, with the "performance" frequency governor
> loaded. An OpenStack Mitaka setup with Distributed Virtual Router.
>=20
> We had some other NIC types in the setup as well.  XPS was also
> enabled on the ConnectX3-Pro.  It was not enabled on the 82599ES (a
> function of the kernel being used, which had it disabled from the
> first reports of XPS negatively affecting VM traffic at the beginning
> of the year)
>=20
> Average Mbit/s From NIC type To Bare Metal BE3:
> NIC Type,
>  CPU on VM Host            Before        After
> ------------------------------------------------
> ConnectX-3 Pro,E5-2670v3    9224         9271
> BE3, E5-2640                9016     9022
> 82599, E5-2640              9192     9003
> BCM57840, E5-2640           9213     9153
> Skyhawk, E5-2640            3884     8897
>=20
> For completeness:
> Average Mbit/s To NIC type from Bare Metal BE3:
> NIC Type,
>  CPU on VM Host            Before        After
> ------------------------------------------------
> ConnectX-3 Pro,E5-2670v3    9322         9144
> BE3, E5-2640            9074     9017
> 82599, E5-2640              8670     8564
> BCM57840, E5-2640           2468 *     7979
> Skyhawk, E5-2640            8897     9269
>=20
> * This is the Busted bnx2x NIC FW GRO implementation issue.  It was
>   not visible in the "After" because the system was setup to disable
>   the NIC FW GRO by the time it booted on the fix kernel.
>=20
> Average Transactions/s Between NIC type and Bare Metal BE3:
> NIC Type,
>  CPU on VM Host            Before        After
> ------------------------------------------------
> ConnectX-3 Pro,E5-2670v3   12421         12612
> BE3, E5-2640            8178      8484
> 82599, E5-2640              8499      8549
> BCM57840, E5-2640           8544      8560
> Skyhawk, E5-2640            8537      8701
>=20
> happy benchmarking,
>=20
> Drew Balliet
> Jeurg Haefliger
> rick jones
>=20
> The semi-cooked results with additional statistics:
>=20
> 554M  - BE3
> 544+M - ConnectX-3 Pro
> 560M - 82599ES
> 630M - BCM57840
> 650M - Skyhawk
>=20
> (substitute is simply replacing a system name with the model of NIC and=
 CPU)
> Bulk To (South) and From (North) VM, Before:
> $ ../substitute.sh vxlan_554m_control_performance_gvnr_dvr_northsouth_s=
tream.log |
> ~/netperf2_trunk/doc/examples/parse_single_stream.py -r -5 -f 1 -f 3 -f=
 4 -f 7 -f 8
> Field1,Field3,Field4,Field7,Field8,Min,P10,Median,Average,P90,P99,Max,C=
ount
> North,560M,E5-2640,554FLB,E5-2640,8148.090,9048.830,9235.400,9192.868,9=
315.980,9338.845,9339.500,113
> North,630M,E5-2640,554FLB,E5-2640,8909.980,9113.238,9234.750,9213.140,9=
299.442,9336.206,9337.830,47
> North,544+M,E5-2670v3,554FLB,E5-2640,9013.740,9182.546,9229.620,9224.02=
5,9264.036,9299.206,9301.970,99
> North,650M,E5-2640,554FLB,E5-2640,3187.680,3393.724,3796.160,3884.765,4=
405.096,4941.391,4956.300,129
> North,554M,E5-2640,554FLB,E5-2640,8700.930,8855.768,9026.030,9016.061,9=
158.846,9213.687,9226.150,135
> South,554FLB,E5-2640,560M,E5-2640,7754.350,8193.114,8718.540,8670.612,9=
026.436,9262.355,9285.010,113
> South,554FLB,E5-2640,630M,E5-2640,1897.660,2068.290,2514.430,2468.323,2=
787.162,2942.934,2957.250,53
> South,554FLB,E5-2640,544+M,E5-2670v3,9298.260,9314.432,9323.220,9322.20=
7,9328.324,9330.704,9331.080,100
> South,554FLB,E5-2640,650M,E5-2640,8407.050,8907.136,9304.390,9206.776,9=
321.320,9325.347,9326.410,103
> South,554FLB,E5-2640,554M,E5-2640,7844.900,8632.530,9199.385,9074.535,9=
308.070,9319.224,9322.360,132
> 0 too-short lines ignored.
>=20
> Bulk To (South) and From (North) VM, After:
>=20
> $ ../substitute.sh vxlan_554m_control_performance_gvnr_xpsfix_dvr_north=
south_stream.log |
> ~/netperf2_trunk/doc/examples/parse_single_stream.py -r -5 -f 1 -f 3 -f=
 4 -f 7 -f 8
> Field1,Field3,Field4,Field7,Field8,Min,P10,Median,Average,P90,P99,Max,C=
ount
> North,560M,E5-2640,554FLB,E5-2640,7576.790,8213.890,9182.870,9003.190,9=
295.975,9315.878,9318.160,36
> North,630M,E5-2640,554FLB,E5-2640,8811.800,8924.000,9206.660,9153.076,9=
306.287,9315.152,9315.790,12
> North,544+M,E5-2670v3,554FLB,E5-2640,9135.990,9228.520,9277.465,9271.87=
5,9324.545,9339.604,9339.780,46
> North,650M,E5-2640,554FLB,E5-2640,8133.420,8483.340,8995.040,8897.779,9=
129.056,9165.230,9165.860,43
> North,554M,E5-2640,554FLB,E5-2640,8438.390,8879.150,9048.590,9022.813,9=
181.540,9248.650,9297.660,101
> South,554FLB,E5-2640,630M,E5-2640,7347.120,7592.565,7951.325,7979.951,8=
365.400,8575.837,8579.890,16
> South,554FLB,E5-2640,560M,E5-2640,7719.510,8044.496,8602.750,8564.741,9=
172.824,9248.686,9259.070,45
> South,554FLB,E5-2640,544+M,E5-2670v3,8838.660,8907.402,9112.335,9114.04=
0,9326.510,9329.062,9329.990,52
> South,554FLB,E5-2640,650M,E5-2640,8699.660,9204.378,9307.940,9269.755,9=
321.060,9328.007,9331.370,58
> South,554FLB,E5-2640,554M,E5-2640,7893.310,8483.182,9111.070,9017.273,9=
314.984,9322.822,9326.750,103
>=20
> Request/Response Before:
> $ ../substitute.sh vxlan_554m_control_performance_gvnr_dvr_northsouth_r=
r.log |
> ~/netperf2_trunk/doc/examples/parse_single_stream.py -r -5 -f 1 -f 3 -f=
 4 -f 7 -f 8
> Field1,Field3,Field4,Field7,Field8,Min,P10,Median,Average,P90,P99,Max,C=
ount
> RR,554FLB,E5-2640,560M,E5-2640,6971.540,8356.420,8515.275,8499.397,8717=
=2E740,9023.489,9114.990,186
> RR,554FLB,E5-2640,630M,E5-2640,7538.530,8461.090,8532.970,8544.005,8665=
=2E414,8895.486,9003.330,119
> RR,554FLB,E5-2640,544+M,E5-2670v3,8825.970,12279.268,12504.175,12421.07=
6,12646.219,12742.536,12831.490,238
>=20
> RR,554FLB,E5-2640,650M,E5-2640,7152.220,8425.368,8535.370,8537.314,8757=
=2E256,9046.692,9128.290,219
>=20
> Request/Response After:
>=20
> $ ../substitute.sh vxlan_554m_control_performance_gvnr_xpsfix_dvr_north=
south_rr.log |
> ~/netperf2_trunk/doc/examples/parse_single_stream.py -r -5 -f 1 -f 3 -f=
 4 -f 7 -f 8
> Field1,Field3,Field4,Field7,Field8,Min,P10,Median,Average,P90,P99,Max,C=
ount
> RR,554FLB,E5-2640,560M,E5-2640,7385.910,8411.654,8568.280,8549.659,8724=
=2E006,8874.092,8971.860,85
> RR,554FLB,E5-2640,630M,E5-2640,8265.030,8472.924,8543.215,8560.117,8657=
=2E339,8900.349,8902.260,34
> RR,554FLB,E5-2640,544+M,E5-2670v3,12365.830,12446.182,12597.575,12612.5=
38,12790.654,12939.399,12968.120,78
>=20
> RR,554FLB,E5-2640,650M,E5-2640,8391.870,8516.924,8672.000,8701.399,8977=
=2E302,9100.178,9130.380,89
> RR,554FLB,E5-2640,554M,E5-2640,6859.680,8390.240,8481.835,8484.884,8649=
=2E290,8850.360,8976.960,226
>=20


--=20
Juerg Haefliger
Hewlett Packard Enterprise


--RqOvSlOHVWWcEUq14Hgcrm5bnEVxNJ14A--

--g7xRMMu7xdX8OULrnpHiou6Tm5xjvcARH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJX92hsAAoJEHVMOpb5+LSMUBAQAIHceAmmv//nkvF6v/9pPAo0
enTYALrBV+HwArVzVmVAKjuhOAZcRMybQEvX2FwzG2IYoCowzaEN6cnEQdzYFjpy
m0SnVjjk3ua7vK3i/KFNg8Wyu9xoAvz844bjoOBEfYG5rBAYVCVopx1Gf6YwnqHL
MiqQt/G+B5J6AGxS5r2rXz/Zzd4mt+G11gZXlGrX04UAVMyCo82Tm7/Evy+1zwo8
2azCoaBFL22PjXYhGIyBbnn+Closz0aU9qXxW/BcgdvEHxBiLti5+2F8CQi4ijAy
E096gKHkD17MWEY24iDjkgP2XB7ueUQF9J5fMBXfgmiSI8awLaHv7EKRXMXe0yGL
4JR8jPiUDLkQHgYwQWfaIqigeaxCEmAiDICXwPwDFwnYofs6HRYbAKDzAOfRh0FS
uUbuGhwrPQgZFGXaTsAeiH0u0keZxLA54Qk+vmJ+ZZf7Hf/pkXTh0PkWm3XEtwYJ
OLOwlp8WW7aX4r++dWD3Ka19u3mQxToLuNmhDGG0MVytP0WDSZDGyjDz1l91LxqJ
xFi4hMPNZ6V6FzJrlEeL18+YYW1e6kSaHErNu5P5KEnWT1ugE+GL5WIg1a7JMuCP
WQGVbAJ9IPgSu7bhNQqBvPc+AhYR6Zn0RUJeJ4p1R25+cQ5odZjMDT0J+68TBjqd
pskEHm0C/xd1qHcwYe13
=LR6v
-----END PGP SIGNATURE-----

--g7xRMMu7xdX8OULrnpHiou6Tm5xjvcARH--
