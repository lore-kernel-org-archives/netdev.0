From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Mon, 6 Feb 2017 18:56:34 +0100
Message-ID: <20170206175634.GA18938@salvia>
References: <20170203091231.10142-1-jonas@southpole.se>
 <20170206110858.GA3896@salvia>
 <3efa90fe-3f66-1da0-6038-4fbf9ec2b7ce@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: laforge@gnumonks.org, netdev@vger.kernel.org
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55174 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751492AbdBFR4m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 12:56:42 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 5CEE81395C9
        for <netdev@vger.kernel.org>; Mon,  6 Feb 2017 18:56:41 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4D23CDA7E0
        for <netdev@vger.kernel.org>; Mon,  6 Feb 2017 18:56:41 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 168ABDA818
        for <netdev@vger.kernel.org>; Mon,  6 Feb 2017 18:56:39 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <3efa90fe-3f66-1da0-6038-4fbf9ec2b7ce@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jonas,

On Mon, Feb 06, 2017 at 02:33:07PM +0100, Jonas Bonn wrote:
> Hi Pablo,
> 
> On 02/06/2017 12:08 PM, Pablo Neira Ayuso wrote:
> >Hi Jonas,
> >
> >On Fri, Feb 03, 2017 at 10:12:31AM +0100, Jonas Bonn wrote:
> >>The GTP-tunnel driver is explicitly GGSN-side as it searches for PDP
> >>contexts based on the incoming packets _destination_ address.  If we
> >>want to write an SGSN, then we want to be idenityfing PDP contexts
> >>based on _source_ address.
> >>
> >>This patch adds a "flags" argument at GTP-link creation time to specify
> >>whether we are on the GGSN or SGSN side of the tunnel; this flag is then
> >>used to determine which part of the IP packet to use in determining
> >>the PDP context.
> >So far the implementation that I saw in osmocom relies on userspace code
> >to tunnel data from ME to the SSGN/SGW running on the base station.
> >
> >The data we get from GGSN -> SGSN needs to be places into a SN-PDU (via
> >SNDCP) when sending it to the BTS, right? So I wonder how this can be
> >useful given that we would need to see real IP packets coming to the
> >SSGN that we tunnel into GTP.
> 
> Fair enough.  The use-case I am looking at involves PGW load-testing where
> the simulated load is generated locally on the SGSN so it _is_ seeing IP
> packets and the SNDCP is left out altogether.  Perhaps this is too
> pathological to warrant messing with the upstream driver... I don't know:
> the symmetry does not cost much even if it's of limited use.

Thanks for explaining your use-case.

If some basic form of this load-testing tool ends up serving everyone,
ie. landing some code in the libgtpnl library that we can all use to
benchmark/stress test this driver, then I would be glad to take this.

Thanks!
