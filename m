From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net: bridge: add per-port group_fwd_mask with
 less restrictions
Date: Fri, 29 Sep 2017 08:14:20 -0700
Message-ID: <20170929081420.3b069170@xeon-e3>
References: <1506517964-17479-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        bridge@lists.linux-foundation.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:57160 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752326AbdI2PO3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 11:14:29 -0400
Received: by mail-pf0-f176.google.com with SMTP id g65so865526pfe.13
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 08:14:29 -0700 (PDT)
In-Reply-To: <1506517964-17479-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Sep 2017 16:12:44 +0300
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> We need to be able to transparently forward most link-local frames via
> tunnels (e.g. vxlan, qinq). Currently the bridge's group_fwd_mask has a
> mask which restricts the forwarding of STP and LACP, but we need to be able
> to forward these over tunnels and control that forwarding on a per-port
> basis thus add a new per-port group_fwd_mask option which only disallows
> mac pause frames to be forwarded (they're always dropped anyway).
> The patch does not change the current default situation - all of the others
> are still restricted unless configured for forwarding.
> We have successfully tested this patch with LACP and STP forwarding over
> VxLAN and qinq tunnels.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

LACP is fine, but STP must not be forwarded if STP in user or kernel
mode is enabled.

Please update this patch or revert it.
