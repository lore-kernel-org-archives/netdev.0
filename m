From: Crestez Dan Leonard <cdleonard@gmail.com>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Thu, 23 Oct 2014 17:46:06 +0300
Message-ID: <CAJdmCrKTg89nv0XKSHW8atHfQu-cKe_Dg7Kpv8bYyO38H2oNJQ@mail.gmail.com>
References: <5447FDB2.2010906@gmail.com> <544886C4.4020702@gmail.com>
 <1414041833.2094.28.camel@edumazet-glaptop2.roam.corp.google.com>
 <1414042688.2094.30.camel@edumazet-glaptop2.roam.corp.google.com>
 <5448A72D.1050806@cumulusnetworks.com> <1414070490.2094.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:41631 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbaJWOq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 10:46:27 -0400
Received: by mail-qa0-f53.google.com with SMTP id v10so777527qac.12
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 07:46:26 -0700 (PDT)
In-Reply-To: <1414070490.2094.39.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 23, 2014 at 4:21 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-10-23 at 02:58 -0400, Jonathan Toppins wrote:
>
>> > +           if (!pool) {
>> > +                   pool = kzalloc_node(sizeof(*pool), GFP_KERNEL,
>> GFP_DMA | GFP_KERNEL
>> This memory will possibly be used in a DMA correct? (thinking crypto
>> hardware offload)
>
> I am not sure this is the case, but this certainly can be added.
As far as I know what GFP_DMA actually does is restrict allocation to
low memory addresses under 24 bits for very old devices. There is also
GFP_DMA32 which restricts to addresses under 32 bytes (for device
which don't support 64 bit addresses).

This kind of stuff only belongs in device drivers where the exact
hardware limitations are known. I don't think crypto devices with this
kind of limitations can be exposed through the crypto API that the
md5sig feature uses.

--
Regards,
Leonard
