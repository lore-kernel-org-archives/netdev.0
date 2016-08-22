From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH] ethtool: Add support for SCTP verification tag
 in Rx NFC
Date: Mon, 22 Aug 2016 08:32:17 -0700
Message-ID: <CAKgT0UesygYza46L4H7aQxeDZtsFfQTWt5gQSu5cqsRg-rSd4A@mail.gmail.com>
References: <147164234934.15412.10180837031828143039.stgit@ahduyck-desk.amr.corp.intel.com>
 <1471738910.13300.114.camel@decadent.org.uk> <CAKgT0UcPgOzgH3S6WHLUx4H_DXovHKGj=g57rYxGVp2WiYOEcA@mail.gmail.com>
 <1471871150.13300.137.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:36705 "EHLO
        mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756121AbcHVPcT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 11:32:19 -0400
Received: by mail-yw0-f182.google.com with SMTP id u134so54613360ywg.3
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 08:32:18 -0700 (PDT)
In-Reply-To: <1471871150.13300.137.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 6:05 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Sat, 2016-08-20 at 18:56 -0700, Alexander Duyck wrote:
>> > On Sat, Aug 20, 2016 at 5:21 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
>> >
>> > On Fri, 2016-08-19 at 14:32 -0700, Alexander Duyck wrote:
>> > >
>> > > The i40e hardware has support for SCTP filtering via Rx NFC however the
>> > > default configuration expects us to include the verification tag as a part
>> > > of the filter.  In order to support that I need to be able to transfer that
>> > > data through the ethtool interface via a new structure.
>> > >
>> > > This patch adds a new structure to allow us to pass the verification tag
>> > > for IPv4 or IPv6 SCTP traffic.
>> > [...]
>> >
>> > This looks like an incompatible ABI change.  I suppose it could be OK
>> > if no drivers implemented flow steering for SCTP using the previously
>> > specified structure, but have you checked that that is the case?
>> >
>> > Ben.
>>
>> Well the structure itself matches the TCP flow spec for the TCP flow
>> sized portion.  All I am doing with this patch is adding an extension
>> to that which is still confined to the 52 byte limit of the flow
>> > union.
>
> But that extension will be ignored by any drivers that implemented the
> API as previously defined.  (If there aren't any, as I said, this
> doesn't really matter.)

The ixgbe driver supports sctp already, and was using the TCP flow
spec to do it.

> With previous extensions (everything in struct ethtool_flow_ext) we've
> introduced new type flags to ensure that they won't be silently
> ignored.  You could add a new extended-SCTP type value for the same
> reason.

I guess I could go the extended flow route.  I an just define a new
type for SCTP_V4 and SCTP_V6.

> [...]
>> One thing I could do if you would like would be to spin up another
>> patch to force the kernel to return -EINVAL if we are masking in
>> fields that are out of bounds for the flow specification.  That way we
>> can handle this  a bit more concisely in the future should we end up
>> > having to extend any other flow specifications.
>
> It's too late to do that now.

I disagree.  For now what I can do is lock down the existing flow
specifications so nobody tries to cheat and smuggle data in on the
unused space and for the new extended specifications we make sure that
they are included in a mask verification so that if we have to add any
new fields they will already be checked for.

I'll make sure to include such a patch for v2.

Thanks.

- Alex
