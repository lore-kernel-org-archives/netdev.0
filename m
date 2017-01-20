From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next v2] ipmroute: add support for
 RTNH_F_UNRESOLVED
Date: Fri, 20 Jan 2017 09:42:14 -0800
Message-ID: <20170120094214.4d01938e@xeon-e3>
References: <1484921062-23379-1-git-send-email-nikolay@cumulusnetworks.com>
        <1484921721-24378-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34266 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752412AbdATRmW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:42:22 -0500
Received: by mail-pf0-f172.google.com with SMTP id e4so23932958pfg.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 09:42:22 -0800 (PST)
In-Reply-To: <1484921721-24378-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jan 2017 15:15:21 +0100
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> This patch adds a new field that is printed in the end of the line which
> denotes the real entry state. Before this patch an entry's IIF could
> disappear and it would look like an unresolved one (iif = unresolved):
> (3.0.16.1, 225.11.16.1)          Iif: unresolved
> with no way to really distinguish it from an unresolved entry.
> After the patch if the dumped entry has RTNH_F_UNRESOLVED set we get:
> (3.0.16.1, 225.11.16.1)          Iif: unresolved  State: unresolved
> for unresolved entries and:
> (0.0.0.0, 225.11.11.11)          Iif: eth4       Oifs: eth3  State: resolved
> for resolved entries after the OIF list. Note that "State:" has ':' in
> it so it cannot be mistaken for an interface name.
> 
> And for the example above, we'd get:
> (0.0.0.0, 225.11.11.11)          Iif: unresolved     State: resolved
> 
> Also when dumping all routes via ip route show table all, it will show
> up as:
> multicast 225.11.16.1/32 from 3.0.16.1/32 table default proto 17 unresolved
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied to net-next
