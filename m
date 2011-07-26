From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: invalid requirement from ethtool?
Date: Tue, 26 Jul 2011 15:42:22 +0300
Message-ID: <20110726124222.GA4842@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38315 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048Ab1GZMm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 08:42:27 -0400
Received: by wwe5 with SMTP id 5so473358wwe.1
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2011 05:42:26 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I see the following text in include/linux/ethtool.h and wonder what is
the reasoning for requiring that both params cannot be zero. I could
not track when and who inserted this text as it dates before git was
used to track kernel code, but my feeling is that is related to a
specific hardware limitation.

        /* How many packets to delay an RX interrupt after
         * a packet arrives.  If 0, only rx_coalesce_usecs is
         * used.  It is illegal to set both usecs and max frames
         * to zero as this would cause RX interrupts to never be
         * generated.
         */
        __u32   rx_max_coalesced_frames;

        /* How many packets to delay a TX interrupt after
         * a packet is sent.  If 0, only tx_coalesce_usecs is
         * used.  It is illegal to set both usecs and max frames
         * to zero as this would cause TX interrupts to never be
         * generated.
         */
        __u32   tx_max_coalesced_frames;

I found this in tg3 driver:
         /* No rx interrupts will be generated if both are zero */
        if ((ec->rx_coalesce_usecs == 0) &&
            (ec->rx_max_coalesced_frames == 0))
                return -EINVAL;

However, bnx2 for example allows setting both to zero.

I think both params zero should be allowed and mean coalescing is not
operational, thus we can remove these comments from ethtool.h
