From: Glen Turner <glen.turner@aarnet.edu.au>
Subject: DHCP and jumbo frames
Date: Mon, 06 Sep 2004 13:49:29 +0930
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094444369.22662.32.camel@andromache>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi folks,

I'm trying to make DHCP work correctly for ethernet jumbo frame media
and jumbo+standard MTU subnets on jumbo media. It's turning into a bit
of a long slog (RFC amendments, etc), but jumbo frames will never seen
widespread host deployment without it.

It turns out that the DHCP client has to be able to select from a range
of potential DHCP offers (all else equal it should select the offer with
the largest MTU) and has to be able to reject an offer with an MTU the
hardware cannot support.

Setting the MTU often re-sets the ethernet controller (as far as I can
tell from the e1000 source). So checking each DHCP offer by attempting
to write the MTU to the hardware isn't going to work well. Especially if
an ethernet controller reset causes the PHY to drop carrier, as spanning
tree hold-downs could then cause the DHCP state machine to time out.

Is there any way for the DHCP client to query every interface for the
MTU size ranges that the interface supports?

Advice is very appreciated,
Glen

-- 
Glen Turner          Tel: (08) 8303 3936 or +61 8 8303 3936
Australia's Academic & Research Network   www.aarnet.edu.au
