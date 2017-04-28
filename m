From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH] net: hso: register netdev later to avoid a race condition
Date: Fri, 28 Apr 2017 21:00:22 +0200
Message-ID: <20170428190022.GV2823@localhost>
References: <1493227600-10102-1-git-send-email-andreas@kemnade.info>
 <20170427084401.GP2823@localhost>
 <20170428193629.4f72caed@aktux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johan Hovold <johan@kernel.org>, davem@davemloft.net,
        joe@perches.com, gregkh@linuxfoundation.org,
        peter@hurleysoftware.com, hns@goldelico.com,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andreas Kemnade <andreas@kemnade.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36788 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1035535AbdD1TA3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 15:00:29 -0400
Content-Disposition: inline
In-Reply-To: <20170428193629.4f72caed@aktux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 28, 2017 at 07:36:29PM +0200, Andreas Kemnade wrote:
> On Thu, 27 Apr 2017 10:44:01 +0200
> Johan Hovold <johan@kernel.org> wrote:
> 
> > On Wed, Apr 26, 2017 at 07:26:40PM +0200, Andreas Kemnade wrote:
> > > If the netdev is accessed before the urbs are initialized,
> > > there will be NULL pointer dereferences. That is avoided by
> > > registering it when it is fully initialized.
> > 
> > > Reported-by: H. Nikolaus Schaller <hns@goldelico.com>
> > > Signed-off-by: Andreas Kemnade <andreas@kemnade.info>

> > This all looks good, but you should consider cleaning up the error
> > handling of this function as a follow-up as we should not be
> > deregistering netdevs that have never been registered (e.g. if a
> > required endpoint is missing or if registration fails for some reason).
> > 
> > But just to be clear, this problem existed also before this change.
> > 
> Just to check wether I am understanding this correctly. In your opinion
> this patch is good for now. And later when it is applied, there should
> be an additional error handling cleanup patch.

Exactly; your patch is fine as is and the error-handling issue can be
fixed separately.

Thanks,
Johan
