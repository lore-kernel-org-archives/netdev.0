From: Quentin Barnes <qbarnes@gmail.com>
Subject: iptables, conntrack, and the raw table vs. L3DSR
Date: Sat, 27 Aug 2016 16:55:38 -0500
Message-ID: <20160827215538.GA36125@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:38674 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752002AbcH0Vzu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 17:55:50 -0400
Received: by mail-it0-f51.google.com with SMTP id g62so46543253ith.1
        for <netdev@vger.kernel.org>; Sat, 27 Aug 2016 14:55:50 -0700 (PDT)
Received: from gmail.com (c-98-212-204-93.hsd1.il.comcast.net. [98.212.204.93])
        by smtp.gmail.com with ESMTPSA id v124sm2202158ita.22.2016.08.27.14.55.47
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Aug 2016 14:55:48 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several years ago, I wrote an iptables module that rewrites packets'
destination addresses based on the value in the DSCP field to
implement Layer 3 Direct Server Return (L3DSR).  The main code of
the iptables target module you can find here:
https://github.com/yahoo/l3dsr/blob/master/linux/kmod-xt/xt_DADDR.c

The iptable-daddr module has been in production since I wrote it
with some limitations.  One of those limitations is it doesn't
work well with conntrack modules.  I believe that's from the daddr
rewriting confuses conntrack since changing a packet's daddr changes
its 4-tuple not allowing conntrack to track a connection.

Someone recently suggested I change the module from the "mangle"
table to "raw", so it can be put in the prerouting chain ahead of
conntrack.  That would let conntrack see the packet after its daddr
update.  This approach seems to work fine in a test case letting
L3DSR and conntrack apparently work in concert, but has me concerned
that there might be unforeseen negative side-effects from using the
raw table for doing mangling work.

Can anyone think of any issues with having a mangle target module be
invoked from the raw table?

Or as an alternative if necessary, is there a possible/rational way
to leave the module in the mangle table and then inform conntrack
about the packet's daddr alteration?

Quentin
