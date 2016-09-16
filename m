From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v2] xen-netback: fix error handling on netback_probe()
Date: Fri, 16 Sep 2016 12:30:18 +0100
Message-ID: <20160916113018.GC21888@citrix.com>
References: <1473952246-27037-1-git-send-email-filipe.manco@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <wei.liu2@citrix.com>,
        <xen-devel@lists.xenproject.org>
To: Filipe Manco <filipe.manco@neclab.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:56332 "EHLO SMTP.CITRIX.COM"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751397AbcIPLaU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 07:30:20 -0400
Content-Disposition: inline
In-Reply-To: <1473952246-27037-1-git-send-email-filipe.manco@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 15, 2016 at 05:10:46PM +0200, Filipe Manco wrote:
> In case of error during netback_probe() (e.g. an entry missing on the
> xenstore) netback_remove() is called on the new device, which will set
> the device backend state to XenbusStateClosed by calling
> set_backend_state(). However, the backend state wasn't initialized by
> netback_probe() at this point, which will cause and invalid transaction
> and set_backend_state() to BUG().
> 
> Initialize the backend state at the beginning of netback_probe() to
> XenbusStateInitialising, and create two new valid state transitions on
> set_backend_state(), from XenbusStateInitialising to XenbusStateClosed,
> and from XenbusStateInitialising to XenbusStateInitWait.
> 
> Signed-off-by: Filipe Manco <filipe.manco@neclab.eu>

Acked-by: Wei Liu <wei.liu2@citrix.com>
