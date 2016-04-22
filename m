From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv6: Do not fix up linklocal and loopback addresses
Date: Fri, 22 Apr 2016 16:14:19 -0600
Message-ID: <571AA23B.3040703@cumulusnetworks.com>
References: <571A4D11.8070307@brocade.com> <571A4DEB.3090204@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Mike Manning <mmanning@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37298 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372AbcDVWOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 18:14:22 -0400
Received: by mail-ig0-f177.google.com with SMTP id g8so28910716igr.0
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:14:22 -0700 (PDT)
In-Reply-To: <571A4DEB.3090204@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/22/16 10:14 AM, Mike Manning wrote:
> commit f1705ec197e7 ("net: ipv6: Make address flushing on ifdown
> optional") added the option to retain user configured addresses on an
> admin down. A comment to one of the later revisions suggested using
> the IFA_F_PERMANENT flag rather than adding a user_managed boolean to
> the ifaddr struct. A side effect of this change is that link local and
> loopback addresses were also retained which was not part of the
> objective of the original changes. The commit 70af921db6f8 ("net: ipv6:
> Do not keep linklocal and loopback addresses") ensures that these are
> no longer kept. Similarly, the present fix ensures that these addresses
> are not incorrectly fixed up.
>
> Testing also with the recent patch in place to delete host routes on
> ifdown still shows that fixup of the LL & loopback addrs is incorrectly
> being attempted (and without that patch was causing a crash in fib6).
> Another approach to this is through code inspection by checking where
> the user_managed flag in the original dahern patch (which we have been
> using for nearly a year) has been replaced by checking IFA_F_PERMANENT.
>
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> ---
>   net/ipv6/addrconf.c |   13 +++++++------
>   1 file changed, 7 insertions(+), 6 deletions(-)
>

Acked-by: David Ahern <dsa@cumulusnetworks.com>
