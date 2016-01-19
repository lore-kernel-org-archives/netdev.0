From: David Decotigny <decot@googlers.com>
Subject: Re: [PATCH V3 1/6] net/ethtool: introduce a new ioctl for per queue setting
Date: Tue, 19 Jan 2016 11:30:21 -0800
Message-ID: <CAG88wWYosRjbdMXXuK2w7rvjmScf2ODaeyVXaaFK8NrLHhDFjA@mail.gmail.com>
References: <1452780487-10581-1-git-send-email-kan.liang@intel.com>
 <1452996017.2519.29.camel@decadent.org.uk> <37D7C6CF3E00A74B8858931C1DB2F077058775A4@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bwh@kernel.org" <bwh@kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"sasha.levin@oracle.com" <sash
To: "Liang, Kan" <kan.liang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35645 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932321AbcASTam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 14:30:42 -0500
Received: by mail-wm0-f44.google.com with SMTP id r129so103906963wmr.0
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 11:30:42 -0800 (PST)
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F077058775A4@SHSMSX103.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a v6 ready, didn't have a chance to test + send it for review.
will try to get done with it by tomorrow morning (PST).

On Sun, Jan 17, 2016 at 6:25 PM, Liang, Kan <kan.liang@intel.com> wrote:
>>
>> On Thu, 2016-01-14 at 09:08 -0500, kan.liang@intel.com wrote:
>> [...]
>> > --- a/include/uapi/linux/ethtool.h
>> > +++ b/include/uapi/linux/ethtool.h
>> > @@ -1144,6 +1144,21 @@ enum ethtool_sfeatures_retval_bits {
>> >  #define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
>> >  #define ETHTOOL_F_COMPAT        (1 << ETHTOOL_F_COMPAT__BIT)
>> >
>> > +#define MAX_NUM_QUEUE              4096
>> > +
>> > +/**
>> > + * struct ethtool_per_queue_op - apply sub command to the queues in
>> mask.
>> > + * @cmd: ETHTOOL_PERQUEUE
>> > + * @sub_command: the sub command which apply to each queues
>> > + * @queue_mask: Bitmap of the queues which sub command apply to
>> > + * @data: A complete command structure following for each of the
>> > +queues addressed  */ struct ethtool_per_queue_op {
>> > +   __u32   cmd;
>> > +   __u32   sub_command;
>> > +   unsigned long
>> queue_mask[BITS_TO_LONGS(MAX_NUM_QUEUE)];
>> [...]
>>
>> I thought we already agreed that this won't work for 32-bit userland on a
>> big-endian 64-bit kernel?
>
> I found David Decotigny's patch. https://lkml.org/lkml/2015/12/14/728
> But it looks like it is not merged yet.
> Any idea when it will be merged to net-next or net?
> So I can build my patch on top of his patch.
>
> Thanks,
> Kan
>
>>
>> Ben.
>>
>> --
>> Ben Hutchings
>> Theory and practice are closer in theory than in practice.
>>                                 - John Levine, moderator of comp.compilers
