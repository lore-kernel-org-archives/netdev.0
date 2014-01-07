From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] vti: get rid of nf mark rule in prerouting
Date: Mon, 6 Jan 2014 20:59:32 -0800
Message-ID: <20140106205932.29553fd2@nehalam.linuxnetplumber.net>
References: <1381245682-15523-1-git-send-email-christophe.gouault@6wind.com>
	<20131011.145304.305063991853045981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: christophe.gouault@6wind.com, netdev@vger.kernel.org,
	amwang@redhat.com, saurabh@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:59818 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbaAGE7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 23:59:39 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so19000189pdj.17
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 20:59:38 -0800 (PST)
In-Reply-To: <20131011.145304.305063991853045981.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Oct 2013 14:53:04 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Christophe Gouault <christophe.gouault@6wind.com>
> Date: Tue,  8 Oct 2013 17:21:22 +0200
> 
> > This patch fixes and improves the use of vti interfaces (while
> > lightly changing the way of configuring them).
>  ...
> > Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
> > ---
> > This is is both a fix and enhancement patch. However, there are 2 ways
> > of fixing the inbound processing bug:
> > - either keep the current configuration model (ikey + netfilter rule)
> >   and change the tunnel lookup method. This patch would then be reverted
> >   by the enhancement (this sounds counterproductive).
> > - or directly change the configuration model (okey, no netfilter rule) and keep
> >   the current tunnel lookup method.
> 
> Ok, applied and queued up for -stable, thanks.

I hate to reply to old threads, but this keeps context.

We have discovered a problem with this patch, it breaks the earlier use of VTI
because it loses the mark applied through iptables. It was not a "light change"
to the way to configure them and should have gotten more review and was not
appropriate for -stable.
