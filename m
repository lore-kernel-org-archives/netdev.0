From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Mon, 6 Feb 2017 18:27:09 +0100 (CET)
Message-ID: <1174391417.758308.1486402029809.JavaMail.zimbra@tpip.net>
References: <20170203091231.10142-1-jonas@southpole.se> <20170206110858.GA3896@salvia> <3efa90fe-3f66-1da0-6038-4fbf9ec2b7ce@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pablo <pablo@netfilter.org>, laforge <laforge@gnumonks.org>,
        netdev <netdev@vger.kernel.org>
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:48513 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750953AbdBFR1M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 12:27:12 -0500
In-Reply-To: <3efa90fe-3f66-1da0-6038-4fbf9ec2b7ce@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jonas,

Sorry, for later reply, I'm currently on vacation with almost no
internet access.

----- On Feb 6, 2017, at 2:33 PM, Jonas Bonn jonas@southpole.se wrote:

> Hi Pablo,
> 
> On 02/06/2017 12:08 PM, Pablo Neira Ayuso wrote:
>> Hi Jonas,
>>
>> On Fri, Feb 03, 2017 at 10:12:31AM +0100, Jonas Bonn wrote:
>>> The GTP-tunnel driver is explicitly GGSN-side as it searches for PDP
>>> contexts based on the incoming packets _destination_ address.  If we
>>> want to write an SGSN, then we want to be idenityfing PDP contexts
>>> based on _source_ address.
>>>
>>> This patch adds a "flags" argument at GTP-link creation time to specify
>>> whether we are on the GGSN or SGSN side of the tunnel; this flag is then
>>> used to determine which part of the IP packet to use in determining
>>> the PDP context.
>> So far the implementation that I saw in osmocom relies on userspace code
>> to tunnel data from ME to the SSGN/SGW running on the base station.
>>
>> The data we get from GGSN -> SGSN needs to be places into a SN-PDU (via
>> SNDCP) when sending it to the BTS, right? So I wonder how this can be
>> useful given that we would need to see real IP packets coming to the
>> SSGN that we tunnel into GTP.
> 
> Fair enough.  The use-case I am looking at involves PGW load-testing
> where the simulated load is generated locally on the SGSN so it _is_
> seeing IP packets and the SNDCP is left out altogether.  Perhaps this is
> too pathological to warrant messing with the upstream driver... I don't
> know: the symmetry does not cost much even if it's of limited use.

Sounds reasonable. I'll review change with that in mind next week.

Andreas

> Couldn't the SNDCP theoretically be a separate node and push IP packets
> to the SGSN, thus making this useful?  Perhaps it's a stretch...
> 
> /Jonas
