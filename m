From: Shawn Warren <shawn.warren@rackspace.com>
Subject: Re: [BUG]ethtool: NIC blink
Date: Tue, 20 May 2014 14:50:47 +0000
Message-ID: <CFA0D571.2E331%shawn.warren@rackspace.com>
References: <CFA0BA5E.2E2E6%shawn.warren@rackspace.com>
 <1400596740.17377.50.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.ord1.rackspace.com ([173.203.4.136]:41795 "EHLO
	mx2.ord1.rackspace.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262AbaETOus convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 10:50:48 -0400
In-Reply-To: <1400596740.17377.50.camel@deadeye.wl.decadent.org.uk>
Content-Language: en-US
Content-ID: <B15A1FECE6D73C43A4669FCD80193852@RACKSPACE.CORP>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ben,

Thank you for sharing this link. This sounds about right for what I saw
but I was not checking the network connections to the server looking fo=
r
RTNL. Once I have a test server up and confirm this I will respond back=
=2E

Thanks,

Shawn Warren
Rackspace hosting



On 5/20/14 9:39 AM, "Ben Hutchings" <ben@decadent.org.uk> wrote:

>[Re-sending with cc to netdev]
>
>On Tue, 2014-05-20 at 12:53 +0000, Shawn Warren wrote:
>> Hello Ben and NetDev,
>>=20
>>=20
>> I am curious how exactly the ethtool =ADp flag works when blinking
>> interface lights. I ran into an issue on a DELL R820 with an Intel
>> proc that when I blinked an interface and put ethtool in the
>> background, the load on the server began steadily increasing. I ran
>> the following command to reproduce the issue:
>>=20
>>=20
>> # ethtool =ADp eth2 3600 &
>>=20
>>=20
>> The load increased until the ethtool process was halted. Is this a
>> known bug/issue?
>
>It's not a bug in the ethtool utility.
>
>Perhaps you have run into the problem explained in
><https://git.kernel.org/linus/68f512f21a64c9b264df6c61a9333e7890faf74b=
>.
>The load will increase as processes wait (uninterruptibly) to obtain t=
he
>RTNL lock.  They will appear as being in D state.
>
>This was fixed in Linux 3.0, but older versions can't practically be
>fixed as it required an incompatible change to the driver API.
>
>Ben.
>
>--=20
>Ben Hutchings
>Life would be so much easier if we could look at the source code.
