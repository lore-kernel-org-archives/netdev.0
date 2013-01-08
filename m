From: "Matthew O'Connor" <liquidhorse@gmail.com>
Subject: balance-alb and arp-reply stomping
Date: Tue, 8 Jan 2013 11:22:29 -0500
Message-ID: <CAK8PzV=GN0+txo=ixnKGGUXEeJMfd8=Ce=bSReg_oJXScbs79g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:54046 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756527Ab3AHQWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 11:22:30 -0500
Received: by mail-ob0-f181.google.com with SMTP id oi10so634792obb.12
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 08:22:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!  I've encountered what appears to be a known "issue" with
balance-alb, whereby when a bond configured thus is put into a bridge
with virtual ethernet adapters, on reply to arp requests the bond
appears to "stomp" the MAC of the outgoing replies with one of its own
adapters' MACs.  The consequence seems to be intermittent
connectivity, easily witnessed by ping-loss early in a virtual
adapter's life.  Checking the ARP cache on another machine shows that
the virtual adapter's MAC has been replaced with one of the bond
slaves'.  Other bonding modes do not exhibit this behavior.

I was wondering if this is something that had been brought up before
for fixing, and whether or not you would accept a patch if an
appropriate fix was implemented?  My naive understanding would suggest
checking the outgoing reply against a table of known slaves, and if
the MAC did not exist there then map it to a slave and transmit the
reply unmodified.

One thing I find strange about this problem: when pinging a host that
is behind said bond and bridge, I occasionally see the virtual
adapter's true MAC appear intermittently even though it would seem
gratuitous ARPs are also getting stomped.  The MAC appears and then
quickly disappears, replaced with one of the bond's slaves.  What's
more, after the virtual adapter has been a member of the bridge for a
good while (several minutes, it seems), the intermittent connectivity
seems less of an issue - for instance, I just pinged one host that
exhibited this problem the other day, and it replied to 370 pings
without a single lost packet.  Ordinarily, when the issue occurs,
50-70% of the packets appear to be lost.

I am not currently a member of this list - please CC me on replies!  THANKS!!

-- Matt
