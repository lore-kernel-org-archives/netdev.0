From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC rocker-net-next 1/6] net: flow: Cancel innermost
 nested attribute first
Date: Tue, 6 Jan 2015 10:03:21 +0900
Message-ID: <20150106010319.GA14077@vergenet.net>
References: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
 <1420440610-20621-2-git-send-email-simon.horman@netronome.com>
 <20150105.161725.1765207203472571760.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:63284 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbbAFBDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 20:03:31 -0500
Received: by mail-pa0-f53.google.com with SMTP id kq14so29880380pab.40
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 17:03:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150105.161725.1765207203472571760.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 05, 2015 at 04:17:25PM -0500, David Miller wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Mon,  5 Jan 2015 15:50:05 +0900
> 
> > Cancel innermost nested attribute first on error when putting flow actions.
> > 
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > 
> > ---
> > 
> > Its unclear to me if this makes any difference.
> > But it seems more logical to me.
> 
> Hmmm.  Be careful here.  nla_nest_cancel() is just rolling back
> the length of the SKB to right before the netlink attribute being
> given as the cancellation point.
> 
> So you really have to cancel attributes in exactly the reverse order
> in which they were added.  Otherwise we'll make a trim call with a
> negative adjustment that actually expands the SKB past an already
> cancelled attribute.

Thanks for clarifying that.

The aim of my patch is to perform the roll back in reverse order
which I now know is required.
