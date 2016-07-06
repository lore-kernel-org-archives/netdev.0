From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [Patch net] ppp: defer netns reference release for ppp channel
Date: Wed, 6 Jul 2016 15:25:15 +0300
Message-ID: <20160706122515.GN4666@uranus>
References: <1467781956-2229-1-git-send-email-xiyou.wangcong@gmail.com>
 <20160706082602.GM4666@uranus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Matt.Bennett@alliedtelesis.co.nz,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	Guillaume Nault <g.nault@alphalink.fr>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34477 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbcGFMZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 08:25:29 -0400
Content-Disposition: inline
In-Reply-To: <20160706082602.GM4666@uranus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 06, 2016 at 11:26:02AM +0300, Cyrill Gorcunov wrote:
> On Tue, Jul 05, 2016 at 10:12:36PM -0700, Cong Wang wrote:
> > Matt reported that we have a NULL pointer dereference
> > in ppp_pernet() from ppp_connect_channel(),
> > i.e. pch->chan_net is NULL.
> > 
> > This is due to that a parallel ppp_unregister_channel()
> > could happen while we are in ppp_connect_channel(), during
> > which pch->chan_net set to NULL. Since we need a reference
> > to net per channel, it makes sense to sync the refcnt
> > with the life time of the channel, therefore we should
> > release this reference when we destroy it.
> > 
> > Fixes: 1f461dcdd296 ("ppp: take reference on channels netns")
> > Reported-by: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
> > Cc: Paul Mackerras <paulus@samba.org>
> > Cc: linux-ppp@vger.kernel.org
> > Cc: Guillaume Nault <g.nault@alphalink.fr>
> > Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> > Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> > ---
> 
> Hi Cong! I may be wrong, but this doesn't look right in general.
> We take the net in ppp_register_channel->ppp_register_net_channel
> and (name) context implies that ppp_unregister_channel does
> the reverse. Maybe there some sync point missed? I'll review
> in detail a bit later.

After staring more I think the patch should be fine as a fix
since implementing sync with ppp_[re|un]register_channel and
ppp_ioctl might need a way more work.

Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>
