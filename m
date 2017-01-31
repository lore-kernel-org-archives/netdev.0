From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next 0/4] sfc: encapsulated filters
Date: Tue, 31 Jan 2017 09:38:37 -0800
Message-ID: <CALx6S36ztVKytRo615kkYbvpwhUYnEcb3tCLmeBfxmmvcr7huw@mail.gmail.com>
References: <9baa375c-b3b1-f640-04fb-e234c85a4e93@solarflare.com>
 <CALx6S359v=kUv2DAgkmDRSdMvM=sk+zYLxLKSAWhZEQwp=aTDQ@mail.gmail.com> <848d3b88-7e6e-4b9e-ba68-967aa45e9552@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-net-drivers@solarflare.com,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35049 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdAaRje (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 12:39:34 -0500
Received: by mail-qk0-f193.google.com with SMTP id u25so24669994qki.2
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 09:38:39 -0800 (PST)
In-Reply-To: <848d3b88-7e6e-4b9e-ba68-967aa45e9552@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 3:42 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 27/01/17 18:03, Tom Herbert wrote:
>> On Fri, Jan 27, 2017 at 7:00 AM, Edward Cree <ecree@solarflare.com> wrote:
>>> This series adds support for setting up filters for encapsulated traffic on
>>> SFC 8000-series adapters, which recognise VXLAN, GENEVE and NVGRE packets by
>>> parsing packet headers.  (VXLAN and GENEVE will only be recognised if the
>>> driver on the primary PF has notified the firmware of relevant UDP ports,
>>> which this driver does not yet do.)
>>> While the driver currently has no way of using these filters for flow
>>> steering, it is nonetheless necessary to insert catch-all (aka 'default')
>>> filters to direct this traffic, similar to the existing unencapsulated uni-
>>> and multi-cast catch-all filters, as otherwise the traffic will be dropped
>>> by the NIC - implementation details of the hardware filtering mean that the
>>> traffic will not get matched on outer MAC address to unencapsulated catch-
>>> all filters.  (Yes, this is a mess.)
>> I don't understand this. You seem to be saying that unless there is
>> filtering for VXLAN and GENEVE these packets will dropped. These are
>> _just_ UDP packets. Anything that the NIC does special for them is at
>> most an optimization, it can *NEVER* be a requirement for NICs to be
>> able to parse these protocols. Please elaborate...
>>
>> Tom
> Unless the NIC has been told to consider a particular UDP port as either VXLAN
> or GENEVE, it _will_ treat it as "_just_ UDP packets" and go through the normal
> filtering.  It's only NVGRE that (without this series) gets dropped.

That doesn't sound much better. NICs have no business to drop any
properly formed IP packet for any IP protocol as a default behavior.
If packets should be dropped that should only be configured by the
user.

> Both before and after this series, the NIC's list of encapsulation UDP ports is
> not set up and is thus empty, so it treats all UDP traffic normally.  In the
> future, this list will be populated by the driver (in order to support inner-
> frame CHECKSUM_UNNECESSARY offload), and the traffic thereby designated as
> encapsulated will hit the inner-frame filters (which this series sets up).
>
> -Ed
