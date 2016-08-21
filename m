From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH] ethtool: Add support for SCTP verification tag
 in Rx NFC
Date: Sat, 20 Aug 2016 18:56:56 -0700
Message-ID: <CAKgT0UcPgOzgH3S6WHLUx4H_DXovHKGj=g57rYxGVp2WiYOEcA@mail.gmail.com>
References: <147164234934.15412.10180837031828143039.stgit@ahduyck-desk.amr.corp.intel.com>
 <1471738910.13300.114.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35780 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751222AbcHUB5F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 21:57:05 -0400
Received: by mail-io0-f179.google.com with SMTP id m101so81287692ioi.2
        for <netdev@vger.kernel.org>; Sat, 20 Aug 2016 18:56:57 -0700 (PDT)
In-Reply-To: <1471738910.13300.114.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 20, 2016 at 5:21 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Fri, 2016-08-19 at 14:32 -0700, Alexander Duyck wrote:
>> The i40e hardware has support for SCTP filtering via Rx NFC however the
>> default configuration expects us to include the verification tag as a part
>> of the filter.  In order to support that I need to be able to transfer that
>> data through the ethtool interface via a new structure.
>>
>> This patch adds a new structure to allow us to pass the verification tag
>> for IPv4 or IPv6 SCTP traffic.
> [...]
>
> This looks like an incompatible ABI change.  I suppose it could be OK
> if no drivers implemented flow steering for SCTP using the previously
> specified structure, but have you checked that that is the case?
>
> Ben.

Well the structure itself matches the TCP flow spec for the TCP flow
sized portion.  All I am doing with this patch is adding an extension
to that which is still confined to the 52 byte limit of the flow
union.  The net result should be that the new value will appear masked
if anything using the new specifier receives a rule using the old
definition and for anything using the new flow spec that sends to the
old code the extra value will be ignored.  I can look into double
checking the behavior to make certain I have that right on Monday.

One thing I could do if you would like would be to spin up another
patch to force the kernel to return -EINVAL if we are masking in
fields that are out of bounds for the flow specification.  That way we
can handle this  a bit more concisely in the future should we end up
having to extend any other flow specifications.

- Alex
