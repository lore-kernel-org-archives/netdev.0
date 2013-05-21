From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH RFC 0/2] Control VF link state
Date: Tue, 21 May 2013 23:12:06 +0300
Message-ID: <CAJZOPZJpPjqxX__+P0eN=XatC8pzY7zJZBQcc3U6tjQycdKB5g@mail.gmail.com>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>
	<1368113074.2653.2.camel@bwh-desktop.uk.solarflarecom.com>
	<CAJZOPZJ052r67==xXciyoTmE8TQwXyx5sVgeuR=dQUEpXkd5WQ@mail.gmail.com>
	<1368146064.4131.279.camel@deadeye.wl.decadent.org.uk>
	<CAJZOPZ+c4HDbd+983qosp+NOmpZ-U3sCWKyKZrEVW_UDhfMEWA@mail.gmail.com>
	<1369082231.4616.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	amirv@mellanox.com, ronye@mellanox.com
To: Ben Hutchings <bhutchings@solarflare.com>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:47416 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751769Ab3EUUMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 16:12:07 -0400
Received: by mail-qa0-f43.google.com with SMTP id j11so2429356qag.2
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 13:12:06 -0700 (PDT)
In-Reply-To: <1369082231.4616.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 20, 2013 at 11:37 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Mon, 2013-05-20 at 23:06 +0300, Or Gerlitz wrote:
>> On Fri, May 10, 2013 at 3:34 AM, Ben Hutchings <bhutchings@solarflare.com> wrote:
>> > Yeah.  In some ways it could be better for a PF driver to create two net
>> > devices, one which acts as a vswitch port and one which bypasses it (if
>> > possible).  But then that's going to confuse people too.  I don't think we can win...
>>
>> >>> Perhaps the default should also be specified?
>>
>>
>> So can we make progress in steps here... e.g deal with the question
>> whether the PF exposes one or two netdevices in a future thread
>
> Definitely, I don't want to derail your proposal.
>
>> and
>> add now code supporting an admin ability to control VF link state (I
>> suggest for the default, e.g when no config directive was applied to
>> be "auto" means follow the PF link state, as was suggested here)?
>
> I think that's a sensible default.
>
>> if
>> we agree on that, do we want new ndo_set_vf_ call or introducr
>> ndo_set_vf_config call which whose param will be further extended each
>> time we add new feature to control/configure?
>
> The risk I see with extensible operations (and which has occurred with
> many ethtool operations) is that drivers may quietly ignore the elements
> they don't implement.  So either (1) add yet another specific operation
> or (2) define a general VF setter, require drivers to set some flags
> that indicate which VF attributes are settable, and check the flags in
> rtnetlink.c before calling into the driver.

both (1) and (2) makes sense to me, I am more leaned to (2), John, do
we have a go from your side to post V1 for net-next? which of the
options makes more sense to you?

Or.
