From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: IPv6 testing - TAHI project on Linux
Date: Mon, 18 Mar 2013 15:00:14 +0200
Message-ID: <CAHG7+CCL-TXLxO_Xqnx3XxRYbv0cLVUUu3i_AMX=8CssMVgYiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Baluta <dbaluta@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:58018 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab3CRNAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 09:00:15 -0400
Received: by mail-qa0-f54.google.com with SMTP id hg5so1608665qab.6
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 06:00:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The TAHI project[1] is a testing framework for the IPv6 network
stack, originally designed for FreeBSD. Using a patch from  Mark Atkinson[2]
we can build and use v6eval on 32bit Linux. We were able to make some changes
and compile it on 64bit with multilib support.[3]

We also wrote some scripts[4] to create a virtual testing environment. The
scripts are able to download, configure and build a kernel then automatically
run the IPv6 core tests with v6eval inside 2 KVM virtual machines.

There are some tests known to fail:
* Spec tests 32, 33, 34, 35, 39, 40, 47, 48
  These fail because the kernel is currently more strict when receiving
  headers with invalid TLV options. So ICMP Parameter Problem is not sent
  for the following bad options.

* Addr tests 3, 5, 14, 15, 23, 24
  These fail when the Node Under Test has global IPv6 addresses configured
  for routing testing. However, the kernel does DAD properly.

If you are going to use the test automation scripts[4], you might also want
to use our modified v6eval-remotes[5]. These are using a SLIP connection for
remote control with SSH, instead of the plain serial connection.

Any feedback is welcome.


[1] - http://www.tahi.org
[2] - http://wundermark.blogspot.ro/2012/02/linux-patches-for-tahi-v6eval-332.html
[3] - https://github.com/IxLabs/tahi-linux/tree/master/v6eval
[4] - https://github.com/IxLabs/tahi-linux/tree/master/scripts
[5] - https://github.com/IxLabs/tahi-linux/tree/master/v6eval-remotes
