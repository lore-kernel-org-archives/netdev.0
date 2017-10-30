From: Saurabh Gupta <sbhjnpr@gmail.com>
Subject: Outgoing interface check in icmpv6_echo_reply()
Date: Mon, 30 Oct 2017 10:47:39 +0530
Message-ID: <CAMvv2Q54+h2P7vhRVjv1zdNC2DiREqTaeLGu185KxGRYF5AcCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:56585 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751568AbdJ3FRk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 01:17:40 -0400
Received: by mail-qk0-f176.google.com with SMTP id l194so14696938qke.13
        for <netdev@vger.kernel.org>; Sun, 29 Oct 2017 22:17:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I need to add a check in icmp6_echo_reply() to drop any packet that is being
sent using address that is not local to any linux interface. Mostly to avoid
icmpv6 stats registering this packet.

/* Dont send if the address is not found on any device */
ret = ipv6_chk_addr_and_flags(net, saddr, NULL, 0, 0);

Would this be a bad idea? My question is if there are any use cases that may
break by introducing this check or any other good reason why such check is not
there already?

I see a similar check in icmp_reply()->__ip_route_output_key_hash () path,
that accomplishes similar logic:

if (!(fl4->flowi4_flags & FLOWI_FLAG_ANYSRC)) {
    /* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
    if (!__ip_dev_find(net, fl4->saddr, false))
        goto out;
}

Any insights here would help.

Thanks
Saurabh
