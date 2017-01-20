From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next] ipmroute: add support for
 RTNH_F_UNRESOLVED
Date: Fri, 20 Jan 2017 15:05:51 +0100
Message-ID: <406f3640-a441-aee2-0a10-1c184a172451@cumulusnetworks.com>
References: <1484921062-23379-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:35895 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752029AbdATOGa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 09:06:30 -0500
Received: by mail-lf0-f47.google.com with SMTP id z134so58982714lff.3
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 06:05:55 -0800 (PST)
In-Reply-To: <1484921062-23379-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/01/17 15:04, Nikolay Aleksandrov wrote:
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
> And for the example above, we'd get:
> (0.0.0.0, 225.11.11.11)          Iif: unresolved     State: resolved
> 
> Also when dumping all routes via ip route show table all, it will show
> up as:
> multicast 225.11.16.1/32 from 3.0.16.1/32 table default proto 17 unresolved
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
>  ip/ipmroute.c | 6 ++++++
>  ip/iproute.c  | 2 ++
>  2 files changed, 8 insertions(+)
> 

Oops, sent the wrong version. v2 coming up, sorry for the noise
