From: Brandon Philips <brandon.philips@coreos.com>
Subject: fib_frontend: Add network specific broadcasts, when it takes a sense
Date: Fri, 9 Dec 2016 16:07:52 -0800
Message-ID: <20161210000752.GA18080@Brandons-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Tom Denham <tom@tigera.io>,
        Aaron Levy <aaron.levy@coreos.com>,
        Brad Ison <bison@coreos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:36751 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751693AbcLJAH4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 19:07:56 -0500
Received: by mail-pg0-f46.google.com with SMTP id f188so12709880pgc.3
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 16:07:56 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello-

A number of us are working on an OSS overlay network system called flannel.
It is used in a variety of Linux container systems and one of the backends
is VXLAN.

The issue we have: when creating the VXLAN interface and assigning it an
address we see a broadcast route being added by the Kernel. For example if
we have 10.4.0.0/16 a broadcast route to 10.4.0.0 is created. This route is
unwanted because we assign 10.4.0.0 to one of our VXLAN interfaces.

However, the Kernel interface bring-up comment reads: Add network specific
broadcasts, when it takes a sense. The code is here:
https://github.com/torvalds/linux/blob/master/net/ipv4/fib_frontend.c#L859-L872

Can someone explain why creation of the broadcast route is non-optional?
Would a patch to make it optional be acceptable? Is it safe for us to
simply delete the route? We have a patch that simply deletes the broadcast
route after interface creation but don't know why the Kernel code "makes
sense".

You can read more information about the issue here:
https://github.com/coreos/flannel/pull/569

Thank You,

Brandon
