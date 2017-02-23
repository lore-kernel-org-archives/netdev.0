From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] net/gtp: Add udp source port generation
 according to flow hash
Date: Thu, 23 Feb 2017 15:00:12 +0100
Message-ID: <20170223140012.GA4462@salvia>
References: <1487257141-11706-1-git-send-email-ogerlitz@mellanox.com>
 <576077949.135577.1487282291666.JavaMail.zimbra@tpip.net>
 <CAJ3xEMijwHpWfxUFcaCiAkP_0P8R2u6Cv4L=Vc3b_dPf+beOBg@mail.gmail.com>
 <CALx6S34ibBFpmZvxAtUn6oqgX9M8C1a3gg1iZrWWzwbswatUSQ@mail.gmail.com>
 <7810166.196078.1487842556962.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        laforge <laforge@gnumonks.org>, netdev <netdev@vger.kernel.org>,
        timo lindhorst <timo.lindhorst@travelping.com>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57628 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750944AbdBWOB7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 09:01:59 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 78C99ED91B
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 15:00:20 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 629CEDA7E0
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 15:00:20 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7EAE6DA80C
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 15:00:13 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <7810166.196078.1487842556962.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 23, 2017 at 10:35:56AM +0100, Andreas Schultz wrote:
> ----- On Feb 22, 2017, at 10:47 PM, Tom Herbert tom@herbertland.com wrote:
[...]
> > This shouldn't be taken as a HW requirement and it's unlikely we'd add
> > explicit GTP support in flow_dissector. If we can't get entropy in the
> > UDP source port then IPv6 flow label is a potential alternative (so
> > that should be supported in NICs for RSS).
> > 
> > I'll also reiterate my previous point about the need for GTP testing--
> > in order for us to be able to evaluate the GTP datapath for things
> > like performance or how they withstand against DDOS we really need an
> > easy way to isolate the datapath.
> 
> GTP as specified is very unsecure by definition. It is meant to be run
> only on *private* mobile carrier and intra mobile carrier EPC networks.
> Running it openly on the public internet would be extremly foolish.
> 
> There are some mechanisms in GTPv1-C on how to handle overload and
> more extensive mechanisms in GTPv2-C for overload handling. The basic
> guiding principle is to simply drop any traffic that it can't handle.
> 
> Anyhow, I havn't seen anything in 3GPP or GSMA documents that deals
> with DDOS.
> 
> There are guidelines like the GSMA's IR.88 that describe how the intra
> carrier roaming should work and what security measures should be
> implemented.
> 
> Traffic coming in at Gi/SGi or form the UE could create a DDOS on tunnel.
> However, on the UE side you still have the RAN (eNODE, SGSN, S-GW) or
> an ePDG that has to apply QoS and thereby limit traffic. On the Gi/SGi
> side side you have the PCEF that does the same.
> 
> So in a complete 3GPP node (GGSN, P-GW) that uses the GTP tunnel
> implementation, malicious traffic should be blocked before it can reach
> the tunnel.
> 
> And as I stated before, the GTP tunnel module is not supposed to be
> use without any of those components. So the DDOS concern should not
> be handled at the tunnel level.

I think that Tom's point is that this tunnel driver will have to deal
with DDOS scenarios anyway, because reality is that you can't always
block it before it can reach the tunnel.

Or's patch helps us deal with this scenario.
