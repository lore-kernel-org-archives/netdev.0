From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: iproute2: segfault with ip link show dev
Date: Wed, 7 Jan 2015 11:42:17 -0800
Message-ID: <20150107114217.42bf2392@urahara>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/h/+X0RrNfgLqhu8dNgY35Bd"; protocol="application/pgp-signature"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:55028 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753874AbbAGTm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 14:42:27 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so6816577pab.7
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 11:42:26 -0800 (PST)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id rj7sm2502981pbc.58.2015.01.07.11.42.24
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jan 2015 11:42:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/h/+X0RrNfgLqhu8dNgY35Bd
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Looks like one VF info changes broke old code

Begin forwarded message:

Date: Wed, 7 Jan 2015 04:06:53 -0800
From: William Dauchy <william@gandi.net>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: iproute2: segfault with ip link show dev


Hi,

I was using iproute2 3.15.
My network card in using igb driver with VF enable, e.g igb.max_vfs=3D2
After upgrading to 3.16, I have now a segfault while doing a
usual `ip link show dev eth1`.
Disabling VFS make the segafult disappear.

Here is the gdb trace even if it does not contain much info.
The segfault occurs when at the VF step.

(gdb) break print_linkinfo
Breakpoint 1 at 0x40782d
(gdb) set args link show dev eth1
(gdb) r
Starting program: /sbin/ip link show dev eth1

Breakpoint 1, 0x000000000040782d in print_linkinfo ()
(gdb) n
Single stepping until exit from function print_linkinfo,
which has no line number information.
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq state UP
mode DEFAULT group default qlen 10000
    link/ether 00:26:6c:ff:b5:c1 brd ff:ff:ff:ff:ff:ff

Program received signal SIGSEGV, Segmentation fault.
0x00000000004070eb in print_vfinfo ()
(gdb) bt
#0  0x00000000004070eb in print_vfinfo ()
#1  0x0000000000407f9f in print_linkinfo ()
#2  0x000000000041f266 in iplink_get ()
#3  0x0000000000409c69 in ipaddr_list_flush_or_save ()
#4  0x000000000040a113 in ipaddr_list_link ()
#5  0x00000000004203f6 in do_iplink ()
#6  0x0000000000405a07 in do_cmd ()
#7  0x000000000040621e in main ()

The expected output is for example:

# ip link show dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq state UP mode =
DEFAULT group default qlen 10000
    link/ether 00:26:6c:ff:b3:8d brd ff:ff:ff:ff:ff:ff
    vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state auto
    vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state auto


I'm using my own kernel build, a stable v3.14.x

Regards,
--=20
William

--Sig_/h/+X0RrNfgLqhu8dNgY35Bd
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUrYwZAAoJEICnf2CVzeR++gAP/RqChMTRYt0QsZblIAs9Fa1q
TtAGMhGNnBAV0zDU0M1o4afE6ny08bOikZ+LcQoxC69NX7eEtDMgAWadw+DehPC0
gu/6UmISV4xHaCFv7/BdikBW8n1TyRElS7CLa7I2KlbDnRnDv070B+K5XBiwK7QX
yMHt6NEQrf8Tz2x5tpKRHW1ffjKYXV96HW/MokYD9/IWZpoZPydbRNSJKdDvji1i
gWgrqReK1KyC2EaX5PW7W+gwrRrz+4n2oVBymzTpffDKpFv2eTzJx2T6lFsu3BRa
F4M1mJu8U6TxvXPx875LheJ+l5qn/FEhEHZjdsmvTbiNvDYo/zVnXQAYtpvK8xdL
3FbWt3DyjOrAOOXgL4p3xLAQHdhIpHZp+mLI0j3JqqVs5sV710i7O9N9CCmiXNi8
q6CDOWXR2cCpCEI0+hbU7iTIZLK/3xiBeRAmPvV1EM2uCkEaAVLH1sU3jhfNDwI2
riqz9z0Pt0H057GCiuG8y08UJloWnpxOVYST0y9FpZHXmWVYFxN6MbkP5+rxjQln
teNiYRQHbt3opPV4CgRvxTJYuDkJhTWsaDOig+nhk+umxMrgmmGbqFDJQgbqxUms
aBBr7bBqVYQ3BVIH0tHciaF+OL53OxF4Sa0Ko0Z4Se9NW4m099+lhuotWjES6NgP
UNkbFukbB3XK7Sg3nH1I
=XRvQ
-----END PGP SIGNATURE-----

--Sig_/h/+X0RrNfgLqhu8dNgY35Bd--
