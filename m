From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: V2.4 policy router operates faster/better than V2.6
Date: Mon, 3 Jan 2005 14:55:24 -0600
Message-ID: <200501031455.26980.jeremy.guthrie@berbee.com>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6658067.kfCW7YP8Jb";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart6658067.kfCW7YP8Jb
Content-Type: multipart/mixed;
  boundary="Boundary-01=_8Eb2BlUDcnK2yQT"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_8Eb2BlUDcnK2yQT
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

I have a dual processor box running Suse 9.1 Ent. that I changed over to th=
e=20
V2.6.10 kernel.  The box has two interfaces in it, both E1000s.  The box=20
receives anywhere from  200mbit to 500+ mbit that it needs to route out to=
=20
other boxes.  The policy routing table is running ~ 150-200 rules.  ie.  da=
ta=20
comes in E3(e1000), is policy routed to a destination sent out E2(e1000).

Under V2.4 kernels, the system will operate just fine and drop few packets =
if=20
any.  ie. right now under V2.4, I have dropped all of three packets.  Under=
=20
2.6, I can watch the RX drop counter increment.  See below.

[h-pr-msn-1 guthrie 1:48pm]~-> ifconfig eth3 ; sleep 10 ; ifconfig eth3
eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
          inet addr:10.253.0.1  Bcast:10.255.255.255  Mask:255.255.255.0
          inet6 addr: fe80::202:b3ff:fed5:7e30/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:132919934 errors:311285 dropped:311285 overruns:247225=
=20
frame:0
          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:2630721320 (2508.8 Mb)  TX bytes:484 (484.0 b)
          Base address:0x22a0 Memory:eff80000-effa0000

eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
          inet addr:10.253.0.1  Bcast:10.255.255.255  Mask:255.255.255.0
          inet6 addr: fe80::202:b3ff:fed5:7e30/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:133847068 errors:325697 dropped:325697 overruns:258546=
=20
frame:0
          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:3102796062 (2959.0 Mb)  TX bytes:484 (484.0 b)
          Base address:0x22a0 Memory:eff80000-effa0000

If I turn off the policy routing, I instantly stop getting RX errors or=20
overruns as it appears the CPU can now pay attention to the packets coming =
in=20
and drop them(as I turned off IP forwarding as well).

V2.4 Kernel mpstat data:
command:  mpstat -P ALL 60
Linux 2.4.21-251-smp (h-pr-msn-1) 12/15/2004

01:16:24 PM  CPU   %user   %nice %system   %idle    intr/s
01:17:19 PM  all    0.16    0.00   50.12   49.72  42114.18
01:17:19 PM    0    0.12    0.00   55.60   44.28  42114.18
01:17:19 PM    1    0.20    0.00   44.65   55.15  42114.18

01:17:19 PM  CPU   %user   %nice %system   %idle    intr/s
01:18:19 PM  all    0.13    0.00   48.49   51.38  42103.08
01:18:19 PM    0    0.13    0.00   31.88   67.98  42103.08
01:18:19 PM    1    0.13    0.00   65.10   34.77  42103.08

V2.6 kernel mpstat data:
command:  mpstat -P ALL 60
Linux 2.6.5-7.111.5-smp (h-pr-msn-1)         12/15/04

13:36:25     CPU   %user   %nice %system %iowait    %irq   %soft   %idle   =
=20
intr/s
13:37:25     all    0.13    0.00    0.15    0.09    2.03   43.14   54.45 =20
25506.53
13:37:25       0    0.17    0.00    0.08    0.18    0.00   16.81   82.76  =
=20
2215.63
13:37:25       1    0.08    0.00    0.20    0.00    4.08   69.49   26.14 =20
23291.34

13:37:25     CPU   %user   %nice %system %iowait    %irq   %soft   %idle   =
=20
intr/s
13:38:24     all    0.14    0.00    0.12    0.12    2.02   42.89   54.71 =20
25900.70
13:38:24       0    0.03    0.00    0.05    0.22    0.00   16.67   83.03  =
=20
2246.10
13:38:24       1    0.25    0.00    0.20    0.03    4.02   69.12   26.40 =20
23654.55

Any insights as to why there would be such a stark difference in performanc=
e=20
between V2.6 and V2.4?

Please advise.

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--Boundary-01=_8Eb2BlUDcnK2yQT
Content-Type: application/pgp-keys;
  name="OpenPGP key 0x719905E5"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=0x719905E5.asc

-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.2.4 (GNU/Linux)

mQGiBDtxSucRBACqnISb8M/pvbF1gUb7iCPB7t6XbFa5237KsRZHBaeugLdtKCw3
8ulxSrEAsDHFgRJ3eFNWXEX5LEu52CI/riyhR9qzWYTtomddLNAOfZpyalKBtyxC
P9nv0WwYxvmEnsrgnfsJ41mVBaW0Ft5f/IbeyxwZbAxqwHJm2nM4QOVYcwCgng9G
Cw79l9J91FaUVNPMcupFLPMD/0u15pANW+jBXeTFBHLjAp60PFROr4Z0ePBdIGqD
bKV6dX7vfPv/rMhaImUozr/rCCllmrzEFwC63WGZ6QGEl9zzB49vdcwEkPZfMneY
j+QNrAc3OA0cRHm07DugnhRpgawJMzuc9UV9kN3CL0p0zZ7Be94YrNb0tEsSfEJQ
kd2zA/4hQoJmYeDf/UgZZnmWsWioay/S6/9s+ENvkd0/QjLYe1SLU6STeBCkmJWe
fk3iSBYpRquj9w+5v8spltu91nhv5K8giTFiidk6inQ70yH/Dz8FKflWuMhbEGUL
SLLXWtWLJUB2wShvMbEpKVIcVn3ylrBZEF7qGNFdiUwqQkVe/7RBSmVyZW15IE0u
IEd1dGhyaWUgKEplcmVteSBNLiBHdXRocmllKSA8amVyZW15Lmd1dGhyaWVAYmVy
YmVlLmNvbT6IZAQTEQIAJAUCQEziyQIbAwUJB+pfZwYLCQgHAwIDFQIDAxYCAQIe
AQIXgAAKCRCq2NoEcZkF5cWLAJ986CQQIz7zVV2z+TgucV3LOYRXDwCaAiwptN0c
quyV1upu4f8GQAtNd9i5Ag0EO3FK8RAIAMi4ZmMfAGAv9n7m3n5HXmAfHARllCv2
2nxzZYMKp9XmAHLl7NbvxOw6rs+hWFufL1QfGxiHaaMTO64gPUi64+kKFWoGwTY5
AfidjLhNFWoP+gNIc1Mi90J6ZQuXwZI+mieRWTQNE4B9R7ZRftBH05Sj63ioqfbr
uPszGXiunM2S8V3z1U/L9GIvqIW7+tiFYmgXMzW7H2ElIV11Nl+AFqihVSqljXvG
Gi6zkD4OAK6O3fRHtjOTf55eZHHlQ+WjgTn+FtrBQFLRwZ+KDaBOymAjdxoxhe3n
+ZDegk+HzWSPzv8929LGTZeTCI1OMTl/S6AXwwwNGiAZjfVXTsa018MAAwUH/2KG
szyDYLLMd72TK7Yojsvltf84ctK+2hscYrYf34MjNu4ODqe0a/1gwxvfvG4zaIQ5
fWJgFzA/JuprE/gFp9JnSAtvrTBTno4KYlwJggkq5KVpfZs5GDN4Q9uecdvJZ17y
EGasTfyxuTnyxdpHtNkn9ehfs1aVPbd4QzolO0N2QZB2YDBw/GPZ6rgeo/XKkzqg
AoIOwlyWVRgGb5Hv93fNOXhbQ+xMpw4uieeBr8p6B/nwlp/o5M6H676aY9JTf9Up
hdbcBKQpe2Zs54grERng/Q9KJqCDFh65BKGMc7ceckSRhzaKwGF3Wa1BSVn/dLsz
d/0FZ9UX1Cs9LsKnRlCITAQYEQIADAUCPbgP6QUJB+pfeAAKCRCq2NoEcZkF5QvZ
AJ0byLfrhE+kbl+PXTRJ9eeU//O/+wCffaUH/md38U3ZkCgxOcRmPqmf3W0=
=03qu
-----END PGP PUBLIC KEY BLOCK-----

--Boundary-01=_8Eb2BlUDcnK2yQT--

--nextPart6658067.kfCW7YP8Jb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB2bE+qtjaBHGZBeURAgEjAJsEepf2zXr5iYSXdm135VDp627O9QCfd/+E
r/oNJpgFcPI8IH8Lw1fUICU=
=Fh1p
-----END PGP SIGNATURE-----

--nextPart6658067.kfCW7YP8Jb--
