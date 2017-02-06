From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Mon, 6 Feb 2017 12:08:58 +0100
Message-ID: <20170206110858.GA3896@salvia>
References: <20170203091231.10142-1-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: laforge@gnumonks.org, netdev@vger.kernel.org
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45018 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750950AbdBFLJF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 06:09:05 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C800611A119
        for <netdev@vger.kernel.org>; Mon,  6 Feb 2017 12:09:01 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id AB05FDA846
        for <netdev@vger.kernel.org>; Mon,  6 Feb 2017 12:09:01 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 75728DA855
        for <netdev@vger.kernel.org>; Mon,  6 Feb 2017 12:08:59 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170203091231.10142-1-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jonas,

On Fri, Feb 03, 2017 at 10:12:31AM +0100, Jonas Bonn wrote:
> The GTP-tunnel driver is explicitly GGSN-side as it searches for PDP
> contexts based on the incoming packets _destination_ address.  If we
> want to write an SGSN, then we want to be idenityfing PDP contexts
> based on _source_ address.
> 
> This patch adds a "flags" argument at GTP-link creation time to specify
> whether we are on the GGSN or SGSN side of the tunnel; this flag is then
> used to determine which part of the IP packet to use in determining
> the PDP context.

So far the implementation that I saw in osmocom relies on userspace code
to tunnel data from ME to the SSGN/SGW running on the base station.

The data we get from GGSN -> SGSN needs to be places into a SN-PDU (via
SNDCP) when sending it to the BTS, right? So I wonder how this can be
useful given that we would need to see real IP packets coming to the
SSGN that we tunnel into GTP.

Thanks!
