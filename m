From: Jonas Bonn <jonas@southpole.se>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Mon, 6 Feb 2017 14:33:07 +0100
Message-ID: <3efa90fe-3f66-1da0-6038-4fbf9ec2b7ce@southpole.se>
References: <20170203091231.10142-1-jonas@southpole.se>
 <20170206110858.GA3896@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([37.247.8.11]:48070 "EHLO mail.southpole.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752764AbdBFNdM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 08:33:12 -0500
In-Reply-To: <20170206110858.GA3896@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

On 02/06/2017 12:08 PM, Pablo Neira Ayuso wrote:
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
> So far the implementation that I saw in osmocom relies on userspace code
> to tunnel data from ME to the SSGN/SGW running on the base station.
>
> The data we get from GGSN -> SGSN needs to be places into a SN-PDU (via
> SNDCP) when sending it to the BTS, right? So I wonder how this can be
> useful given that we would need to see real IP packets coming to the
> SSGN that we tunnel into GTP.

Fair enough.  The use-case I am looking at involves PGW load-testing 
where the simulated load is generated locally on the SGSN so it _is_ 
seeing IP packets and the SNDCP is left out altogether.  Perhaps this is 
too pathological to warrant messing with the upstream driver... I don't 
know: the symmetry does not cost much even if it's of limited use.

Couldn't the SNDCP theoretically be a separate node and push IP packets 
to the SGSN, thus making this useful?  Perhaps it's a stretch...

/Jonas
