From: David Shwatrz <dshwatrz@gmail.com>
Subject: MSG_PROBE is not set
Date: Sun, 14 Jun 2009 13:36:42 +0300
Message-ID: <31436f4a0906140336v241390can463c30d8a576e3a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:51325 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208AbZFNKoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2009 06:44:15 -0400
Received: by fg-out-1718.google.com with SMTP id d23so212776fga.17
        for <netdev@vger.kernel.org>; Sun, 14 Jun 2009 03:44:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

There is something which I am confused about: when the MSG_PROBE is set, it
means that you cannot should not send the packet. For example, in
ip_append_data()
(ipv4/ip_output.c). This flag should be used for example for finding MTU, AFAIK.
I grepped under the net subtree and **there is no place** when the MSG_PROBE
is set. There are about 5-6 files where this value is checked under net.

When you send a packet from userspace using from sendmsg(), the third parameter
is flags.

You can pass flags like MSG_OOB, MSG_PEEK and other flags from bits/socket.h.
However, you **cannot** pass a flag as MSG_PROBE, AFAIK.
It does not appear at all in bits/socket.h. It **does** appear in
linux/socket.h, but this header is
part of the kernel-headers package, so you cannot include it in a user
space application even if you want (so it won't compile).

So, what do you have here: (and please correct me if I am wrong):
when sending a packet with sendmsg(), this should be from userspace.
the kernel checks a flag which cannot be set from user space.
for what is this flag at all ? is it justified to remove it ?


Regards,
Ds
