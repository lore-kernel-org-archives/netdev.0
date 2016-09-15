From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH] xen-netback: fix error handling on
 netback_probe()
Date: Thu, 15 Sep 2016 15:10:04 +0100
Message-ID: <20160915141004.GM15958@citrix.com>
References: <1473768687-27384-1-git-send-email-filipe.manco@neclab.eu>
 <20160914101023.GY15958@citrix.com>
 <c8e11688-cb11-69f6-2c79-daa0f2b3e8b4@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
        Xen-devel <xen-devel@lists.xenproject.org>
To: Filipe Manco <filipe.manco@neclab.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:22117 "EHLO SMTP.CITRIX.COM"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756721AbcIOOKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 10:10:16 -0400
Content-Disposition: inline
In-Reply-To: <c8e11688-cb11-69f6-2c79-daa0f2b3e8b4@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 15, 2016 at 04:05:17PM +0200, Filipe Manco wrote:
> On 14-09-2016 12:10, Wei Liu wrote:
> >CC xen-devel as well.
> >
> >On Tue, Sep 13, 2016 at 02:11:27PM +0200, Filipe Manco wrote:
> >>In case of error during netback_probe() (e.g. an entry missing on the
> >>xenstore) netback_remove() is called on the new device, which will set
> >>the device backend state to XenbusStateClosed by calling
> >>set_backend_state(). However, the backend state wasn't initialized by
> >>netback_probe() at this point, which will cause and invalid transaction
> >>and set_backend_state() to BUG().
> >>
> >>Initialize the backend state at the beginning of netback_probe() to
> >>XenbusStateInitialising, and create a new valid state transaction on
> >>set_backend_state(), from XenbusStateInitialising to XenbusStateClosed.
> >>
> >>Signed-off-by: Filipe Manco <filipe.manco@neclab.eu>
> >There is a state machine right before set_backend_state. You would also
> >need to update that.
> Good point I'll update the diagram.
> 
> After looking at the diagram and for consistency, shouldn't the transition
> Initialising -> InitWait be handled using set_backend_state()? Currently it
> is done directly in netback_probe() code. If you agree I'll submit a v2 with
> these two changes.

That's fine with me.

Wei.
