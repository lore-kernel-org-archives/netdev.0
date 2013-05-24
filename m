From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Regarding processing IGMPv2 reports from a snooping switch
Date: Fri, 24 May 2013 15:31:21 +0530
Message-ID: <CADAe=++aQH+p-4HxOBa6tznOB=CKQbhyFCm=fMv7SZUR34jLVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:36718 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759561Ab3EXKBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 06:01:53 -0400
Received: by mail-ee0-f48.google.com with SMTP id b47so2548328eek.35
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 03:01:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Router -- snooping switch -- host(s)

Router sends a general igmpv2 query which is forwarded to host(s).

Hosts reply back with report messages that they r intrested in group G
(i.e. 234.1.1.1) as destination address.

Let us say report suppression is enabled in igmp snooping switch. So
switch sends a single report message to router with source address as
0.0.0.0 and destination address as group address  G (for e.g.
234.1.1.1).

But linux kernel in multicast router is dropping the packet.

in ipv4/route.c in ip_route_input_mc function

        if (ipv4_is_zeronet(saddr)) {
                if (!ipv4_is_local_multicast(daddr))
                        goto e_inval;

Ideally packet is dropped in above code. Is it expected behaviour ?

Regards,
Ajith
--------------------------------------------
codingfreak.in
