From: Antti Paila <antti.paila@gmail.com>
Subject: iproute2: ip batch processing problem
Date: Fri, 31 Jul 2015 08:34:54 +0300
Message-ID: <CAK4M3OjtNxB8xcmqQ1hVgbkV8i+=oOv9O8A1mMY2c_WM87a2qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:34688 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbbGaFfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 01:35:15 -0400
Received: by ioea135 with SMTP id a135so75246120ioe.1
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 22:35:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am facing an issue when configuring network interfaces with
"ip -force -batch" command. The problem occurs when the batch
file contains commands with both IPv4 and IPv6 addresses. If I run
the following commands in batch mode:

    tunnel add tunnel1 mode gre tos 1 local 192.168.0.1 remote
192.168.1.1 ttl 64 pmtudisc
    a a fd00::200:10:200:0:2/64 dev eth18

I get an error

    Command failed tunnel_batch2:1
    Error: an inet prefix is expected rather than "fd00::200:10:200:0:2/64".

I noticed that while processing the second line in the batch file,
'get_prefix()' is called with argument 'family == AF_INET'. I believe
the family should be in this case AF_INET6. The problem is that
the 'family' argument is fetched from the global variable 'preferred_family'
that was set to AF_INET while processing the first line of
the batch file.

Should the batch mode support mixed IPv4 and IPv6 addresses and if so,
would it make sense to clear the 'preferred_family' variable
before processing each line of the batch file?

-Antti
