From: Peter Samuelson <psamuelson@efolder.net>
Subject: Re: TCP stalls with 802.3ad + bridge + kvm guest
Date: Wed, 1 Aug 2012 09:41:04 -0500
Message-ID: <20120801144104.GN17572@p12n.org>
References: <20120727183840.GE17572@p12n.org>
 <26496.1343419205@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgoerzen@efolder.net
To: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx11.dcmx.net ([207.210.100.175]:53293 "EHLO mx11.dcmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754756Ab2HAOlH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2012 10:41:07 -0400
Content-Disposition: inline
In-Reply-To: <26496.1343419205@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  [Peter Samuelson]
> >    ixgbe [10 Gbit port] -- bonding [802.3ad] -- bridge -- KVM guest
> >
> >It all works, except that with some flows in the KVM guest - I
> >can reproduce using smbclient - transfers keep stalling, such that I'm
> >averaging well under 1 MB/s.  Should be more like 100 MB/s.
> >
> >Oddly, this only occurs when both the 802.3ad and KVM are used:
> >
> >    Server        Agg        Client         TCP stalls
> >    --------------------------------------------------
> >    external      none       KVM guest      no
> >    external      802.3ad    KVM host       no
> >    KVM host      802.3ad    KVM guest      no
> >    external      802.3ad    KVM guest      yes

[Jay Vosburgh]
>       Does the problem happen if the bond is a different mode
> (balance-xor, for example)?

No, the balance-xor mode seems to work normally.  I am testing it with
only a single slave interface, same way I'm testing LACP mode.

>       Do the various stats on the host and guest show any drops?
> E.g., from "netstat -i" and "tc -s qdisc"

I am not sure what to make of 'netstat -i'.  Some test boots, I get
26000 or so RX packets dropped on bond0 and eth2 (the slave interface),
but not during the actual file transfer tests.  The current test boot,
with LACP enabled, 'netstat -i' shows only 19 dropped RX packets from
bond0 (compared to 740k total RX packets), after several test runs.

Thanks,
Peter
