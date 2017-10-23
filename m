From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip maddr: fix filtering by device
Date: Mon, 23 Oct 2017 14:42:24 +0200
Message-ID: <20171023144224.076200d0@shemminger-XPS-13-9360>
References: <20171019082108.40D7AA0EDF@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Petr Vorel <pvorel@suse.cz>,
        Phil Sutter <phil@nwl.cc>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:55580 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932170AbdJWMme (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 08:42:34 -0400
Received: by mail-wm0-f65.google.com with SMTP id u138so9569451wmu.4
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 05:42:33 -0700 (PDT)
In-Reply-To: <20171019082108.40D7AA0EDF@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Oct 2017 10:21:08 +0200 (CEST)
Michal Kubecek <mkubecek@suse.cz> wrote:

> Commit 530903dd9003 ("ip: fix igmp parsing when iface is long") uses
> variable len to keep trailing colon from interface name comparison.  This
> variable is local to loop body but we set it in one pass and use it in
> following one(s) so that we are actually using (pseudo)random length for
> comparison. This became apparent since commit b48a1161f5f9 ("ipmaddr: Avoid
> accessing uninitialized data") always initializes len to zero so that the
> name comparison is always true. As a result, "ip maddr show dev eth0" shows
> IPv4 multicast addresses for all interfaces.
> 
> Instead of keeping the length, let's simply replace the trailing colon with
> a null byte. The bonus is that we get correct interface name in ma.name.
> 
> Fixes: 530903dd9003 ("ip: fix igmp parsing when iface is long")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Applied
