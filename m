From: "cramerj" <cramerj@intel.com>
Subject: RE: ethtool -d no longer works for e1000
Date: Wed, 9 Mar 2005 16:35:47 -0800
Message-ID: <76FA8CF8F1F53240BB5B962A3385A5800256F787@orsmsx405>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Ganesh Venkatesan" <ganesh.venkatesan@gmail.com>, <netdev@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Ben Greear" <greearb@candelatech.com>, "Jon Mason" <jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ah!  Yes, if you're running ethtool 1.8, then this was an issue (or
rather, an annoyance) in e1000.c where we would default to mac_type =
e1000_undefined for any newer hardware.  Continuous updates to this file
for every piece of hardware we released got old pretty quick.  We've
since changed the default mac_type to e1000_82543, which has a basic set
of registers that haven't changed with each hardware release.  And
although the e1000_82546 mac_type exists, it isn't yet being assigned to
the 82546GB hardware (again, see e1000.c), thus the error.

Long story short, an updated ethtool should do the trick.

Thanks,
-Jeb

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com] On
> Behalf Of Ben Greear
> Sent: Wednesday, March 09, 2005 3:42 PM
> To: Jon Mason
> Cc: Ganesh Venkatesan; netdev@oss.sgi.com
> Subject: Re: ethtool -d no longer works for e1000
> 
> Ben Greear wrote:
> > Jon Mason wrote:
> >
> >> I don't see this problem at all on my 2.6.11-rc4-mm1 kernel
(Athlon64
> >> proc).
> >
> >
> > I think I see the problem.  ethtool -d eth0 works for me,
> > but ethtool -d eth1 does not, even with both are e1000
> > NICs.  It appears it cannot handle reading the second NIC for
> > some reason?
> 
> Errr, my bad.  The problem is more that the dual-port pro/1000 NICs
> don't seem to work, but the built-in e1000s do.
> 
> The chipset that does not work correctly is: 82546GB
> 
> The NICs with chipset: 82541EI seem to work just fine.
> 
> Ben
> 
> 
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
> 
