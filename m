From: Abhijeet Dharmapurikar <adharmap@codeaurora.org>
Subject: IPV6 address lifetime update
Date: Wed, 15 Dec 2010 11:33:38 -0800
Message-ID: <4D091812.8060109@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:32784 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755176Ab0LOTdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 14:33:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Our product uses Linux kernel 2.6.35.  For IPV6 support, the device is=20
using stateless address configuration. We see the global scope address=20
is assigned correctly when the network interface transitions to UP=20
state.  However, we are seeing issue where subsequent router=20
advertisement (RA) messages for assigned prefix results in *new* IPV6=20
address on same interface and duplicate-address-detection for same.  Ou=
r=20
goal is to have the subsequent router RA message simply update the=20
address lifetime for existing IPV6 address(es) using the specific prefi=
x=20
per RFC2462 section 5.5.3(e).  Looking at /net/ipv6/addrconf.c function=
=20
addrconf_prefix_rcv(), it does not seem like updating existing addresse=
s=20
only (without new address creation) is supported.  Is this correct?  Or=
=20
what configuration options are required to achieve the desired behavior=
?
Below is an excerpt from =91ip addr=92 output, showing interface state =
after=20
a few RA messages have been received.  Note we have configured the=20
router to send RA frequently for testing purposes.  Ideally only one=20
global address will be present, with lifetime updated on each RA arriva=
l=20
for same prefix.
Thank you in advance for guidance on this issue.

3: net0: <UP,LOWER_UP> mtu 1280 qdisc pfifo_fast qlen 1000
     link/[530]
     inet6 2002:c023:9c17:c23:f2f9:6c83:be61:a743/64 scope global dynam=
ic
        valid_lft 7170sec preferred_lft 3570sec
     inet6 2002:c023:9c17:c23:1282:1b78:75dd:b9ed/64 scope global dynam=
ic
        valid_lft 7150sec preferred_lft 3550sec
     inet6 2002:c023:9c17:c23:5326:714d:e25b:797e/64 scope global dynam=
ic
        valid_lft 7134sec preferred_lft 3534sec
     inet6 2002:c023:9c17:c23:488c:95c8:34a2:587f/64 scope global dynam=
ic
        valid_lft 7117sec preferred_lft 3517sec
     inet6 fe80::97e0:7661:c51d:bdb/64 scope link
        valid_lft forever preferred_lft forever
