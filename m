From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next] vxlan: do real refcnt for vn_sock
Date: Thu, 30 May 2013 20:56:18 -0700
Message-ID: <20130530205618.0d3a8d16@nehalam.linuxnetplumber.net>
References: <1369739242-5944-1-git-send-email-amwang@redhat.com>
	<20130528214142.4e41db6f@nehalam.linuxnetplumber.net>
	<1369816780.12227.21.camel@cr0>
	<1369968945.5304.1.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:57840 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825Ab3EaD4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 23:56:23 -0400
Received: by mail-pb0-f41.google.com with SMTP id xb12so1514007pbc.28
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 20:56:23 -0700 (PDT)
In-Reply-To: <1369968945.5304.1.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 31 May 2013 10:55:45 +0800
Cong Wang <amwang@redhat.com> wrote:

> On Wed, 2013-05-29 at 16:39 +0800, Cong Wang wrote:
> > On Tue, 2013-05-28 at 21:41 -0700, Stephen Hemminger wrote:
> > > Why not just fix the requirement to drop rtnl when calling igmp.
> > > The code comes out cleaner and safer as well.
> > 
> > Besides you forget to lock the socket before calling _ip_mc_join_group()
> > (and also the order is very important too), your patch doesn't fix the
> > problem I met. The full backtrace is below:
> > 
> 
> Hi, Stephen,
> 
> Do you think my patch is an easier solution? It at least fixes the
> crash, while your patch doesn't. :)
> 
> 

No. your patch doesn't fix the real problem.
The real fix is more complex because of how socket locking interacts with RTNL.


I have been busy with health stuff, so the going is slow.
