From: =?iso-8859-1?Q?Jos=E9_Alexandre_Ventura?= <jose.ventura@efacec.com>
Subject: SMSC LAN9512 PowerPC Linux Driver Problem
Date: Tue, 9 Oct 2012 11:01:34 +0000
Message-ID: <4A56411E-6E5F-489A-B6DA-4A527528B785@efacec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?An=EDbal_Almeida_Pinto?= <anibal.pinto@efacec.com>,
	=?iso-8859-1?Q?Jos=E9_Alexandre_Ventura?= <jose.ventura@efacec.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.efacec.com ([213.58.212.93]:51379 "HELO mail1.efacec.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751278Ab2JILOK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 07:14:10 -0400
Content-Language: en-US
Content-ID: <E934F3AD114E164BBEBE64B93C61A600@efacec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I'm having problems with an SMSC EVB9512, based on the LAN9512 chip, wh=
en using with a PowerPC Chip. The Driver I'm using is the one already p=
rovided by Linux.
I have tested the EVB9512 in two test configurations, both using a Powe=
rPC:

=46irst Test Configuration:
- Custom Board with PowerPC Fresscale MPC8378  @ 667MHz
- Linux Kernel 3.0.0
- EVB9512 connected via USB

Problems with First Test Configuration:
- nmap reports ports has filtered, even thought they are open
- can't establish any connection, even a TCP socket
- can ping the Board with other Devices without a problem

I have made more tests and found out that even though I can receive and=
 send packages, my TX packages had incorrect TCP checksum.
I then used ethtool to disable TX Checksum offloading and all my proble=
ms were solved. The problem with this 'fix' is that it uses more CPU an=
d when under heavy load, I get an error and the ethernet port is shut.


Second Configuration:
- PowerBook G4 1.5GHz, 1.25MB DDR333
- Ubuntu Live CD 12.04 LTS
- EVB9512 connected via USB

Problems with second Configuration:
- TX packets appears as errors in ifconfig
- The powerbook is pinged from another machine without a problem but th=
e PowerBook can't ping the other device

I have also tested the EVB9512 with a Custom Card with an OMAP L138 and=
 also tested with a Toshiba Notebook with an Intel Core i5, both withou=
t any problems. This shows that it is not a problem with the EVB9512 it=
self because it works correctly with other architectures. I think the p=
roblems lies in the PowerPC driver of the LAN95xx.


Best Regards,
Jos=E9 Ventura
