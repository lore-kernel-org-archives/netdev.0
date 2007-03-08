From: Chris Stromsoe <cbs@cts.ucla.edu>
Subject: Re: skge- "soft lockup on CPU#0" with mtu=9000 (2.6.20.1 + web100
 patch)
Date: Thu, 8 Mar 2007 14:23:56 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0703081350510.25051@potato.cts.ucla.edu>
References: <Pine.LNX.4.64.0703081101390.21717@potato.cts.ucla.edu>
 <20070308113427.6344a7f6@freekitty> <Pine.LNX.4.64.0703081256440.25051@potato.cts.ucla.edu>
 <20070308134811.38a8ec81@freekitty>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-4.smtp.ucla.edu ([169.232.46.137]:50973 "EHLO
	smtp-4.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030811AbXCHWYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 17:24:53 -0500
In-Reply-To: <20070308134811.38a8ec81@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Mar 2007, Stephen Hemminger wrote:
> On Thu, 8 Mar 2007 13:31:13 -0800 (PST)
> Chris Stromsoe <cbs@cts.ucla.edu> wrote:
>
>> Thanks.  That fixes the soft lockup.
>>
>> I've got another problem now.  The cards I'm using are dual port
>> (sk-9844).  I am bonding both ports together.
>>
>> The card presents as eth2 and eth3.  If I remove eth2 from the bond so
>> that eth3 is the active interface, I get a hard lock (nothing prints to
>> serial console, sysrq isn't responsive) and have to power cycle.
>>
>> This is with plain 2.6.20.1.  I also tested using skge.[ch] from the
>> current netdev git tree.
>
> Which form of bonding failover, there are locking issues with some
> of the bonding modes. You should ask on the bonding mailing list.

It's active-backup.  Testing with the same setup and e100 works fine. 
I've done a few tests without the bonding module, using the dual-port 
separately.

Testing with bonding and skge:

1) ifenslave bond0 eth2 eth3
    ifenslave -d bond0 eth3
    ifenslave -d bond0 eth2   <-- locks up here

2) ifenslave bond0 eth2 eth3
    ifenslave -d bond0 eth2   <-- locks up here

3) ifenslave bond0 eth3 eth2
    ifenslave -d bond0 eth2
    ifenslave bond0 eth2
    ifenslave bond0 -d eth3
    ifenslave bond0 eth3
    ifenslave -d bond0 eth2   <-- locks up here


Testing without bonding:

1) ip link set mtu 9000 eth2  <-- eth2 is no longer responsive
    ip link set mtu 1500 eth2  <-- eth2 remains unresponsive

2) ifup eth2
    ifdown eth2

    perl -pi -e 's/eth2/eth3/' /etc/network/interfaces

    ifup eth3   <--  locks up here




-Chris
