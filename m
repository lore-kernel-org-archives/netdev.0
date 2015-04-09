From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH] ipvlan: fix up broadcast MAC filtering for ARP and DHCP
Date: Wed, 8 Apr 2015 18:08:14 -0700
Message-ID: <CAF2d9jgU44Q6ij4JvCe2mtP-4+AxLyMT_7X=QNhEnJZjSMxtCQ@mail.gmail.com>
References: <1427409698.18540.11.camel@redhat.com> <CAF2d9jjF20puZvoAD502rAzYAaraRtpZZRK-=vcZGu-Uv4wZMA@mail.gmail.com>
 <1427749308.1913.28.camel@redhat.com> <CAF2d9jipTV4f4NOgGRY-kGOyRBe5HAH6T-mj4G9FYnc7oyc+NA@mail.gmail.com>
 <1427771158.1913.35.camel@redhat.com> <1427775770.30696.3.camel@redhat.com>
 <CAF2d9jikrJU0k3sS=awZQN+SD46qnN4r0bubjXZiY7K9vQieEQ@mail.gmail.com>
 <1427921700.6874.8.camel@redhat.com> <CAF2d9jgqJBfWVnX1mye5xMfYznA_NFte3dEEKG5CyogXTM73Rw@mail.gmail.com>
 <1427985636.5282.9.camel@redhat.com> <CAF2d9jjBtSptfmFY2BDF7ULNxAz=WtUVpNz0iExyd-h+v+4GSQ@mail.gmail.com>
 <1428340638.16890.15.camel@redhat.com> <063D6719AE5E284EB5DD2968C1650D6D1CB1668E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dan Williams <dcbw@redhat.com>,
	linux-netdev <netdev@vger.kernel.org>,
	"jbenc@redhat.com" <jbenc@redhat.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vn0-f51.google.com ([209.85.216.51]:43522 "EHLO
	mail-vn0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754716AbbDIBIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 21:08:35 -0400
Received: by vnbg7 with SMTP id g7so18239727vnb.10
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 18:08:35 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB1668E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 8, 2015 at 2:37 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Dan Williams
> ...
>> > Probably something similar where turn on the broadcast bit and wait
>> > for the interface to get configured (2 min timer) and at the expiry
>> > decide what is to be done about braodcast bit. If the addresses
>> > configured are all IPv6, then eliminate it and if any of them are IPv4
>> > then don't change it. In this case no special casing nor snooping is
>> > required and this should work for dual-stack scenario as well.
>>
>> This does not work for the case where, after configuring, the DHCPv4
>> address lease expires and the IPv4 address is removed, and then DHCPv4
>> is started again.  Possibly because the DHCP server was gone for a short
>> time.  The only way to handle that is to snoop again.
>>
>> Reaching for maximum performance is great, but if that is done by
>> ignoring/breaking a whole class of normal use-cases, I don't think
>> that's reasonable.  It's like saying "gee, I'd love UDP to be faster, so
>> I'll remove anything TCP-related in the kernel".
>>
>> Also, I don't think the snooping is as bad for performance as you may
>> think.  The only relevant issue here is L2 + IPv6-only, and in that case
>> it's 4 extra compares (dhcp4_seen, ipv4cnt, lyr3h, and addr_type) for
>> the external case.  How much is that really going to slow things down,
>> versus breaking a huge part of IPv4 address configuration?
>
> How much performance do you really gain from disabling broadcasts in hardware?
> (Unless your network has massive broadcast storms - which are a different problem).
> I can imagine it helping a low power device stay idle.
>
IPvlan is a virtual driver and is enabling / disabling broadcast on
these virtual links. So N virtual links mean N*clone and that's the
cost.

> For DHCP you have bigger issues.
> All the versions of the dhcp client I've seen use the bpf interface for
> receive traffic (even once started) so you get the cost of a clone
> of every received packet.
>
>         David
>
