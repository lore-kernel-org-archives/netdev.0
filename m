From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 3/3] vxlan: Remote checksum offload
Date: Tue, 25 Nov 2014 10:54:26 -0800
Message-ID: <CAEP_g=8OEDNdA46zrnL+z8cw2pnHkoZySyHKLX6cfj1L6VcBYA@mail.gmail.com>
References: <1416873150-12260-1-git-send-email-therbert@google.com>
 <1416873150-12260-4-git-send-email-therbert@google.com> <CAEP_g=9_6Rq9Ssr_2q4MKfSDxeL23rbExP5ziHbeCL0Nx-VTvw@mail.gmail.com>
 <CA+mtBx-2gHrFfgWhMjtH=XhyYyYh+57W1YL9x3bUiO8nJjA4YA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:34169 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751796AbaKYSyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 13:54:47 -0500
Received: by mail-qg0-f42.google.com with SMTP id z107so926319qgd.1
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 10:54:46 -0800 (PST)
In-Reply-To: <CA+mtBx-2gHrFfgWhMjtH=XhyYyYh+57W1YL9x3bUiO8nJjA4YA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2014 at 6:50 PM, Tom Herbert <therbert@google.com> wrote:
> On Mon, Nov 24, 2014 at 5:06 PM, Jesse Gross <jesse@nicira.com> wrote:
>> On Mon, Nov 24, 2014 at 3:52 PM, Tom Herbert <therbert@google.com> wrote:
>>> Add support for remote checksum offload in VXLAN. This commandeers a
>>> reserved bit to indicate that RCO is being done, and uses the low order
>>> reserved eight bits of the VNI to hold the start and offset values in a
>>> compressed manner.
>>
>> Why do you think that this is OK for you to do? It's clear that there
>> is no consensus for this (and in fact there are other proposals that
>> use that bit in a different way).
>
> I asked on nvo3 list (which I believe is the appropriate forum) what
> the best way to do this is but haven't gotten any response. I will ask
> again-- I would assume that with an implementation and data in hand
> that might be better basis for discussion.
>
> The flag bit is currently unused in the Linux implementation, so I
> don't think it can break anything as of now. I suppose we could make
> RCO for VXLAN a config option and possibly change to use a different
> if consensus is reached on the right approach in the future.

This will definitely break things if this is applied now and the bit
is later used for a different purpose in the future as there will be
no way to update existing deployments.

There are a ton of conflicting proposals in this space so I think
there are only two possible solutions at this point:
 * Potentially support all of them and chose a variant at runtime
though a series of configuration options. This seems ugly,
particularly for GRO.
 * Stick to the version described in the RFC.

I don't think the third alternative of protocol design by order of
patch submission is viable.
