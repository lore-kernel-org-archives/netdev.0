From: Merlin Davis <me.the.wizard@gmail.com>
Subject: Kernel Panic Sending Frames Using dev_queue_xmit()
Date: Wed, 25 Sep 2013 00:32:55 -0700
Message-ID: <CAFu7c2V+gubfzG4HdWtPWJ-w2x3J-RToUT2mdahcKSgn66fDzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:38919 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689Ab3IYHc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 03:32:56 -0400
Received: by mail-vc0-f179.google.com with SMTP id ht10so4012045vcb.38
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 00:32:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am getting kernel panics in the 3.5.0 kernel (and 2.6.39) when
sending Ethernet frames using allocated SKBs passed to
dev_queue_xmit() from a kernel module.  I have trimmed the problem to
a very small module that continually sends the same (captured and
verified) frame from one net_device.  The frames are sent without a
socket in I believe the same way that net/ipv4/arp.c creates and sends
them.  The panic can occur after a few seconds or a few minutes, but
always occurs.  It is USUALLY a "kernel NULL pointer dereference" and
USUALLY occurs within __kfree_skb(), but both the error and the
location can vary.  I have not been successful in capturing a complete
oops message.

There is a GitHub repository with the module, a makefile, and more
notes about how I have tested and what I have tried at
https://github.com/me-the-wizard/ksend

I do not know if there is something I am doing wrong with the SKBs or
if I have stumbled upon a bug in the kernel.  After weeks of attempts
I believe I have reached the limit of my ability to figure this out.
Can anyone offer some guidance?

Thank you,
Merlin
