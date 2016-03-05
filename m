From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [iproute PATCH] libnetlink: Double the dump buffer size
Date: Sat, 05 Mar 2016 22:12:16 +0100
Message-ID: <1457212336.3032.3.camel@sipsolutions.net>
References: <8e235f49b8314d70bbf76709a81c4d84@HQ1WP-EXMB11.corp.brocade.com>
	 <20160304153553.47e8741d@xeon-e3> (sfid-20160305_003554_298078_24E675A8)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>, Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:44558 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750801AbcCEVMX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2016 16:12:23 -0500
In-Reply-To: <20160304153553.47e8741d@xeon-e3> (sfid-20160305_003554_298078_24E675A8)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-03-04 at 15:35 -0800, Stephen Hemminger wrote:
>=C2=A0
> > There have been reports about 'ip addr' printing "Message
> > truncated" on
[...]
> I thought this was addressed in kernel by making the VF info
> optional.
> The netlink protocol is showing some strain, this is one of them.

I don't know how the dump is split here, but we had a similar issue
with nl80211 - originally each physical device info had to fit into a
single message (one message during dump for each device), but we fixed
that by having userspace to set a flag when it's able to understand a
multi-message single physical device info.

Before:
=C2=A0msg1: phy1: A, B, C
=C2=A0msg2: phy2: A, B, C

After:
=C2=A0msg1: phy1: A
=C2=A0msg2: phy1: B
=C2=A0msg3: phy1: C
=C2=A0msg4: phy1: D
=C2=A0msg5: phy2: A
=C2=A0[...]

=46or userspace not setting the flag, it only get partial info today fo=
r
compatibility (A, B, C, not D), but in our particular case this was
perfectly reasonable since it would be unaware of the new capabilities
anyway.

I don't know precisely enough what the issue at hand is to comment
whether such an approach will be feasible here, but it seems it could
be.

johannes
