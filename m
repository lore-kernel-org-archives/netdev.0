From: Aristide Fattori <joystick@security.dico.unimi.it>
Subject: Null pointer dereference in icmp_send
Date: Mon, 16 May 2011 23:06:32 +0200
Message-ID: <BANLkTi=uBDOQOJJMGn6V0Ne7OjQ7kGc-2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: roberto.paleari@emaze.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44764 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab1EPVGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 17:06:53 -0400
Received: by bwz15 with SMTP id 15so4209756bwz.19
        for <netdev@vger.kernel.org>; Mon, 16 May 2011 14:06:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everybody,

in function icmp_send() (net/ipv4/icmp.c), the parameter passed to
dev_net() function is not properly validated. This can lead to a NULL
pointer dereference that crashes the kernel. The bug can be triggered
remotely, by flooding the target with fragmented IPv4 packets.
Important fields in the IP packet are:
 * Flags: the MF flag must be set.
 * Fragment ID: using pseudo-random values for this field quickly
fills fragmented queues in the victim's kernel, as it is unable to
easily reassemble received packets.
 * TOS: using pseudo-random values for this field triggers the
creation of more than one route cache entry for the same destination
address, increasing the chances of incurring in the error condition
described before.
Other fields of the packet do not really matter, and they can be set
to arbitrary values.

If you are interested, we can provide a small and very dirty python
script that easily triggers the error condition.

Greetings,
Aristide Fattori
Roberto Paleari

-- 
GnuPG Key on keyserver.pgp.com ID 0x25578128
http://security.dico.unimi.it/~joystick/
