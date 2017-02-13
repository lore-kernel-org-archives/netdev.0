From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Mon, 13 Feb 2017 12:52:09 +0100 (CET)
Message-ID: <1384904207.69904.1486986729381.JavaMail.zimbra@tpip.net>
References: <20170203091231.10142-1-jonas@southpole.se> <1107124975.65949.1486977919253.JavaMail.zimbra@tpip.net> <20170213111640.GA1458@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jonas Bonn <jonas@southpole.se>, laforge <laforge@gnumonks.org>,
        netdev <netdev@vger.kernel.org>
To: pablo <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:34817 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751652AbdBMLwM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 06:52:12 -0500
In-Reply-To: <20170213111640.GA1458@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

----- On Feb 13, 2017, at 12:16 PM, pablo pablo@netfilter.org wrote:

> On Mon, Feb 13, 2017 at 10:25:19AM +0100, Andreas Schultz wrote:
>> Hi,
>> 
>> I'm a bit late to comment, but maybe you can consider an additional
>> change for v2...
>> 
>> ----- On Feb 3, 2017, at 10:12 AM, Jonas Bonn jonas@southpole.se wrote:
>> 
>> > The GTP-tunnel driver is explicitly GGSN-side as it searches for PDP
>> > contexts based on the incoming packets _destination_ address.  If we
>> > want to write an SGSN, then we want to be idenityfing PDP contexts
>> > based on _source_ address.
>> > 
>> > This patch adds a "flags" argument at GTP-link creation time to specify
>> > whether we are on the GGSN or SGSN side of the tunnel; this flag is then
>> > used to determine which part of the IP packet to use in determining
>> > the PDP context.
>> > 
>> > Signed-off-by: Jonas Bonn <jonas@southpole.se>
>> > ---
>> > 
>> > drivers/net/gtp.c            | 43 ++++++++++++++++++++++++++++++++-----------
>> > include/uapi/linux/gtp.h     |  2 +-
>> > include/uapi/linux/if_link.h |  5 +++++
>> > 3 files changed, 38 insertions(+), 12 deletions(-)
>> > 
>> > diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
>> > index 50349a9..1bbac69 100644
>> > --- a/drivers/net/gtp.c
>> > +++ b/drivers/net/gtp.c
>> > @@ -72,6 +72,7 @@ struct gtp_dev {
>> > 	struct net		*net;
>> > 	struct net_device	*dev;
>> > 
>> > +	unsigned int		flags;
>> 
>> This should IMHO not go into the gtp_dev, the right place
>> is the PDP context.
> 
> So you want to allow mixed configurations where some PDP ctx may be in
> SGSN mode while others in GGSN.
> 
> This doesn't make any sense to me. On top of this, don't forget this
> is just for testing, so I don't see any valid usecase for such a fine
> grain thing.

You are right, running such a configuration does not make sense.
However, when I wrote this the PDP context looked like the most
sensible palace to me.

Anyhow, thinking about this again, I think that integrating that flag
in a rewrite of the validation logic in the Rx path make more sense.
Currently we validate the MS as soon as we have found the PDP context.
This should be delayed a bit and the validation should happen after
pulling the GTP header and right before injecting the payload into
the net device. The flag would then indeed go into the gtp_dev.

Andreas
