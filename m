From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: LRO/GRO and libpcap packet reordering
Date: Thu, 14 Mar 2013 15:45:11 -0700
Message-ID: <CALCETrUidEuaxBeDdDwGb=Dx5iGm1CK-HGWNXRUev5xoR9fnRg@mail.gmail.com>
References: <CALCETrXT036Aoaum+uUV_Of0AFdUZ3eq0QjMjxiCJR4n8AZRTQ@mail.gmail.com>
 <1363298294.2695.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f170.google.com ([209.85.128.170]:62195 "EHLO
	mail-ve0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982Ab3CNWpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 18:45:34 -0400
Received: by mail-ve0-f170.google.com with SMTP id 14so2193202vea.29
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 15:45:33 -0700 (PDT)
In-Reply-To: <1363298294.2695.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 14, 2013 at 2:58 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Thu, 2013-03-14 at 13:37 -0700, Andy Lutomirski wrote:
>> (I'm on Ubuntu's 3.5.0-23, but I haven't seen anything that would
>> change this behavior in newer kernels.)
>>
>> I have a myri10ge device that's attached to a port mirror.  It runs
>> tcpdump.  Most of the traffic I'm capturing has another machine
>> attached to this switch as an endpoint.  That machine is considerably
>> faster than the machine doing the capturing.
>>
>> My captures show nasty artifacts: packets are reodered between a given
>> flow and the other direction of the same flow.  The nasty case is when
>> an ACK shows up before the packet that it's acking.  This thoroughly
>> screws up Wireshark's TCP sequencing analysis.  Turning off LRO and
>> GRO fixes it.
>>
>> Clearly, since this interface doesn't actually have an IP address,
>> there's no good reason to keep GRO and LRO on.  Nonetheless, it would
>> be nice if GRO didn't coalesce packets when there's an intervening
>> packing in the other direction on the same flow.  Can this be done
>> cheaply?
>
> No, it would not be cheap.
>

Hmm.  What if the GRO flow hashing was something like hash(one
endpoint) ^ hash(the other endpoint)?  (NB: I don't really know what
I'm talking about.)

> You'll probably have to disable GRO, LRO and also RSS (unless you can
> configure the RSS hash function to produce the same result for both
> directions of a flow).
>

RSS was already off.  That was the first thing I tried.

--Andy
