From: Peter Samuelson <psamuelson@efolder.net>
Subject: Re: TCP stalls with 802.3ad + bridge + kvm guest
Date: Tue, 31 Jul 2012 09:07:23 -0500
Message-ID: <20120731140723.GK17572@p12n.org>
References: <20120727183840.GE17572@p12n.org>
 <26496.1343419205@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgoerzen@efolder.net
To: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx11.dcmx.net ([207.210.100.175]:36931 "EHLO mx11.dcmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752135Ab2GaOHl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2012 10:07:41 -0400
Content-Disposition: inline
In-Reply-To: <26496.1343419205@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> >    ixgbe [10 Gbit port] -- bonding [802.3ad] -- bridge -- KVM guest
> >
> >(There's also a VLAN layer, but I can reproduce this problem without
> >it.)  It all works, except that with some flows in the KVM guest - I
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
> 	Does the "none" for Agg (the first line) mean no bonding at all?

Correct.  'None' is without the bonding driver, putting the eth
interface directly on the bridge.  (With or without a VLAN layer.)

> 	Does the problem happen if the bond is a different mode
> (balance-xor, for example)?

This is taking me longer to test, as I have to also update the switch
port config, which required coordination with coworkers.  I'll get that
info as soon as I can.

> 	Do the various stats on the host and guest show any drops?
> E.g., from "netstat -i" and "tc -s qdisc"

Yes, 'netstat -i' on the KVM host shows a few dropped RX packets on
bond0 - looks like it increments by 2 each time I do a test download of
my 20MB file.  'tc -s qdisc' on the KVM host shows nothing, and I see
no drops on the KVM guest side.

I'll get the switch reconfigured not to do LACP so I can test other
bonding modes, as you suggest.  Thanks for the quick response!  Sorry
my own followup was delayed....

Peter
