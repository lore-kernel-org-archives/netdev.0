From: Ani Sinha <ani@arista.com>
Subject: subtle change in behavior with tun driver
Date: Wed, 21 Jan 2015 14:36:17 -0800
Message-ID: <CAOxq_8NJdFV6fbVh-uns3bpaKNjtcGEOEDb4U3_rX3d+w85SWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: mst@redhat.com, "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:56240 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbbAUWgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 17:36:39 -0500
Received: by mail-ig0-f175.google.com with SMTP id hn18so3871003igb.2
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 14:36:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys :

Commit 5d097109257c03 ("tun: only queue packets on device") seems to
have introduced a subtle change in behavior in the tun driver in the
default (non IFF_ONE_QUEUE) case. Previously when the queues got full
and eventually sk_wmem_alloc of the socket exceeded sk_sndbuf value,
the user would be given a feedback by returning EAGAIN from sendto()
etc. That way, the user could retry sending the packet again.
Unfortunately, with this new  default single queue mode, the driver
silently drops the packet when the device queue is full without giving
userland any feedback. This makes it appear to userland as though the
packet was transmitted successfully. It seems there is a semantic
change in the driver with this commit.

If the receiving process gets stuck for a short interval and is unable
to drain packets and then restarts again, one might see strange packet
drops in the kernel without getting any error back on the sender's
side. It kind of feels wrong.

Any thoughts?

Ani
