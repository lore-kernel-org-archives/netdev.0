From: "Elior, Ariel" <Ariel.Elior@cavium.com>
Subject: qed*: debug infrastructures
Date: Mon, 24 Apr 2017 17:38:57 +0000
Message-ID: <CY1PR0701MB1337FA26F1503FC9928B0340901F0@CY1PR0701MB1337.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "Tayar, Tomer" <Tomer.Tayar@cavium.com>,
        "Dupuis, Chad" <Chad.Dupuis@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0082.outbound.protection.outlook.com ([104.47.33.82]:27346
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S972465AbdDXRjA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 13:39:00 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

According to the recent messages on the list indicating debugfs is not the =
way
to go, I am looking for some guidance on what is. dpipe approach was
mentioned as favorable, but I wanted to make sure molding our debug feature=
s to
this infrastructure will result in something acceptable. A few points:

1.
One of our HW debug features is a signal recording feature. HW is configure=
d to
output specific signals, which are then continuously dumped into a cyclic
buffer on host. There are ~8000 signals, which can be logically divided to =
~100
groups. I believe this can be modeled in dpipe (or similar tool) as a set o=
f
~100 tables with ~80 entries each, and user would be able to see them all a=
nd
choose what they like. The output data itself is binary, and meaningless to
"the user". The amount of data is basically as large a contiguous buffer as
driver can allocate, i.e. usually 4MB. When user selects the signals, and s=
ets
meta data regarding to mode of operations, some device configuration will h=
ave
to take place. Does that sound reasonable?
This debug feature already exists out of tree for bnx2x and qed* drivers an=
d is
*very* effective in field deployments. I would very much like to see this a=
s an
in-tree feature via some infrastructure or another.

2.
Sometimes we want to debug the probe or removal flow of the driver. ethtool=
 has
the disadvantage of only being available once network device is available. =
If a
bug stops the load flow before the ethtool debug paths are available, there=
 is
no way to collect a dump. Similarly, removal flows which hit a bug but do r=
emove
the network device, can't be debugged from ethtool. Does dpipe suffer from =
the
same problem? qed* (like mlx*) has a common-functionality module. This allo=
ws
creating debugfs nodes even before the network drivers are probed, providin=
g a
solution for this (debug nodes are also available after network driver remo=
val).
If dpipe does hold an answer here (e.g. provide preconfiguration which woul=
d
kick in when network device registers) then we might want to port all of ou=
r
register dump logic over there for this advantage. Does that sound reasonab=
le?

3.
Yuval mentioned this, but I wanted to reiterate that the same is necessary =
for
our storage drivers (qedi/qedf). debugfs does have the advantage of being n=
on
sub-system specific. Is there perhaps another non subsystem specific debug
infrastructure which *is* acceptable to the networking subsystem? My guess =
is
that the storage drivers will turn to debugfs (in their own subsystem).

Thanks,
Ariel
