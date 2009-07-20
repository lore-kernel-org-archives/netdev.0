From: Zsolt SZALAI <zs.szalai@gmail.com>
Subject: getaddrinfo - too many recvmsg calls
Date: Mon, 20 Jul 2009 09:05:56 +0200
Message-ID: <dffc28000907200005p7effca1cif4060b15be99e84@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f228.google.com ([209.85.218.228]:35292 "EHLO
	mail-bw0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbZGTHF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 03:05:57 -0400
Received: by bwz28 with SMTP id 28so1781276bwz.37
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2009 00:05:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I'm working with a host that contains sometimes thousands of virtual
ip address.
One of our third-party application calls getaddrinfo for
sanity-checking the given IP.
I've noticed that recvmsg calls inside getaddrinfo are proportioned to
the number of VIPs, causing high system load and "hanging" user
experience when there are lots of VIPs and also the sanitychecks may
have to happen 2-5 times in a second.

The sanitycheck is now really simple, just a
    addrinfo hints = { 0, AF_INET, 0, 0, 0, NULL, NULL, NULL };
    int result = getaddrinfo(ipAddress, NULL, &hints, &addresses);
call.

I've also noticed that when the vips are configured with `ip` and not
with `ifconfig`, the number of recvmsg calls drops down by a 0.5
multiplier.

Could you advise some other method or optimized execution for this
checks for the environment described?
Or should it be just skipped?

Thanks,
Zsolt Szalai
