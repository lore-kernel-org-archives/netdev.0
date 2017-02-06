From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Mon, 6 Feb 2017 18:25:28 +0100 (CET)
Message-ID: <701545846.758208.1486401928426.JavaMail.zimbra@tpip.net>
References: <20170203091231.10142-1-jonas@southpole.se> <20170206110858.GA3896@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jonas Bonn <jonas@southpole.se>, laforge <laforge@gnumonks.org>,
        netdev <netdev@vger.kernel.org>
To: pablo <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:60041 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750953AbdBFRZb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 12:25:31 -0500
In-Reply-To: <20170206110858.GA3896@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- On Feb 6, 2017, at 12:08 PM, pablo pablo@netfilter.org wrote:

> Hi Jonas,
> 
> On Fri, Feb 03, 2017 at 10:12:31AM +0100, Jonas Bonn wrote:
>> The GTP-tunnel driver is explicitly GGSN-side as it searches for PDP
>> contexts based on the incoming packets _destination_ address.  If we
>> want to write an SGSN, then we want to be idenityfing PDP contexts
>> based on _source_ address.
>> 
>> This patch adds a "flags" argument at GTP-link creation time to specify
>> whether we are on the GGSN or SGSN side of the tunnel; this flag is then
>> used to determine which part of the IP packet to use in determining
>> the PDP context.
> 
> So far the implementation that I saw in osmocom relies on userspace code
> to tunnel data from ME to the SSGN/SGW running on the base station.
> 
> The data we get from GGSN -> SGSN needs to be places into a SN-PDU (via
> SNDCP) when sending it to the BTS, right? So I wonder how this can be
> useful given that we would need to see real IP packets coming to the
> SSGN that we tunnel into GTP.

Uhm, no, absolutely not. The SGSN is not seeing IP packets, it's seeing
stuff that is supposed to put into GTP tunnels. The only instance in an
EPC (apart from a UE), that knows about the payload content of a GTP tunnel
is the GGSN/PGW. Even with Rel 13 Non IP bearers and CIoT optimization,
the interpretation of the content of an bearer is only done at the PGW.

Andreas
> 
> Thanks!
