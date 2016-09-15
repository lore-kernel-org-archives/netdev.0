From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: MDB offloading of local ipv4 multicast groups
Date: Fri, 16 Sep 2016 00:28:57 +0200
Message-ID: <20160915222857.GE10784@lunn.ch>
References: <ebb1092f-4fab-c490-0553-b108feb5e8d4@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Elad Raz <eladr@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Ido Schimmel <idosch@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        "David S. Miller" <davem@davemloft.net>
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49731 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757285AbcIOW3B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 18:29:01 -0400
Content-Disposition: inline
In-Reply-To: <ebb1092f-4fab-c490-0553-b108feb5e8d4@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 15, 2016 at 08:58:50PM +0200, John Crispin wrote:
> Hi,
> 
> While adding MDB support to the qca8k dsa driver I found that ipv4 mcast
> groups don't always get propagated to the dsa driver. In my setup there
> are 2 clients connected to the switch, both running a mdns client. The
> .port_mdb_add() callback is properly called for 33:33:00:00:00:FB but
> 01:00:5E:00:00:FB never got propagated to the dsa driver.
> 
> The reason is that the call to ipv4_is_local_multicast() here [1] will
> return true and the notifier is never called. Is this intentional or is
> there something missing in the code ?

Hi John

I've not looked too deeply at this yet, but here is my take on how it
should work.

By default, the switch needs to flood all multicast traffic from any
port in a bridge, to all other ports in a bridge, including the host.

Adding an mdb entry allows you to reduce where such flooding should
occur, i.e. it allows you to implement IGMP snooping and block traffic
going out a port when you know there is nobody interested in the
traffic on that port.

	Andrew
