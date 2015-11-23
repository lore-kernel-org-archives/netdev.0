From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: Ignore EADDRNOTAVAIL errors during address
 flush operation
Date: Mon, 23 Nov 2015 15:59:39 -0800
Message-ID: <20151123155939.6664468d@xeon-e3>
References: <1446753257-10716-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33939 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804AbbKWX73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 18:59:29 -0500
Received: by padhx2 with SMTP id hx2so633083pad.1
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 15:59:29 -0800 (PST)
In-Reply-To: <1446753257-10716-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  5 Nov 2015 14:54:17 -0500
Neil Horman <nhorman@tuxdriver.com> wrote:

> I found recently that, if I disabled address promotion in the kernel, that
> ip addr flush dev <dev>
> 
> would fail with an EADDRNOTAVAIL errno (though the flush operation would in fact
> flush all addresses from an interface properly)
> 
> Whats happening is that, if I add a primary and multiple secondary addresses to
> an interface, the flush operation first ennumerates them all with a GETADDR |
> DUMP operation, then sends a delete request for each address.  But the kernel,
> having promotion disabled, deletes all secondary addresses when the primary is
> removed.  That means, that several delete requests may still be pending in the
> netlink request for addresses that have been removed on our behalf, resulting in
> EADDRNOTAVAIL return codes.
> 
> It seems the simplest thing to do is to understand that EADDRUNAVAIL isn't a
> fatal outcome on a flush operation, as it just indicates that an address which
> you want to remove is already removed, so it can safely be ignored.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Stephen Hemminger <stephen@networkplumber.org>
> CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

Applied, thanks
