From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Re: Regarding processing IGMPv2 reports from a snooping switch
Date: Mon, 27 May 2013 06:45:34 +0530
Message-ID: <CADAe=+Kf+khMreH91-zWDX8839nC_rB63EvfxPC+qefy==c8aw@mail.gmail.com>
References: <CADAe=++aQH+p-4HxOBa6tznOB=CKQbhyFCm=fMv7SZUR34jLVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:37204 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755619Ab3E0BQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 21:16:06 -0400
Received: by mail-ee0-f43.google.com with SMTP id d41so3750873eek.16
        for <netdev@vger.kernel.org>; Sun, 26 May 2013 18:16:04 -0700 (PDT)
In-Reply-To: <CADAe=++aQH+p-4HxOBa6tznOB=CKQbhyFCm=fMv7SZUR34jLVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ideally IGMPv2 report packet with source address as zero should be
processed as per the standard.

Is there any special reason why the packet is dropped ?

Regards,
Ajith
--------------------------------------------
codingfreak.in


On Fri, May 24, 2013 at 3:31 PM, Ajith Adapa <adapa.ajith@gmail.com> wrote:
> Hi,
>
> Router -- snooping switch -- host(s)
>
> Router sends a general igmpv2 query which is forwarded to host(s).
>
> Hosts reply back with report messages that they r intrested in group G
> (i.e. 234.1.1.1) as destination address.
>
> Let us say report suppression is enabled in igmp snooping switch. So
> switch sends a single report message to router with source address as
> 0.0.0.0 and destination address as group address  G (for e.g.
> 234.1.1.1).
>
> But linux kernel in multicast router is dropping the packet.
>
> in ipv4/route.c in ip_route_input_mc function
>
>         if (ipv4_is_zeronet(saddr)) {
>                 if (!ipv4_is_local_multicast(daddr))
>                         goto e_inval;
>
> Ideally packet is dropped in above code. Is it expected behaviour ?
>
> Regards,
> Ajith
> --------------------------------------------
> codingfreak.in
