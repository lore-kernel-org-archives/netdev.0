From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] vxlan: do real refcnt for vn_sock
Date: Fri, 31 May 2013 12:12:11 +0800
Message-ID: <1369973531.5304.4.camel@cr0>
References: <1369739242-5944-1-git-send-email-amwang@redhat.com>
	 <20130528214142.4e41db6f@nehalam.linuxnetplumber.net>
	 <1369816780.12227.21.camel@cr0> <1369968945.5304.1.camel@cr0>
	 <20130530205618.0d3a8d16@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17321 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763Ab3EaEMX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 May 2013 00:12:23 -0400
In-Reply-To: <20130530205618.0d3a8d16@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-30 at 20:56 -0700, Stephen Hemminger wrote:
> On Fri, 31 May 2013 10:55:45 +0800
> Cong Wang <amwang@redhat.com> wrote:
> 
> > On Wed, 2013-05-29 at 16:39 +0800, Cong Wang wrote:
> > > On Tue, 2013-05-28 at 21:41 -0700, Stephen Hemminger wrote:
> > > > Why not just fix the requirement to drop rtnl when calling igmp.
> > > > The code comes out cleaner and safer as well.
> > > 
> > > Besides you forget to lock the socket before calling _ip_mc_join_group()
> > > (and also the order is very important too), your patch doesn't fix the
> > > problem I met. The full backtrace is below:
> > > 
> > 
> > Hi, Stephen,
> > 
> > Do you think my patch is an easier solution? It at least fixes the
> > crash, while your patch doesn't. :)
> > 
> > 
> 
> No. your patch doesn't fix the real problem.
> The real fix is more complex because of how socket locking interacts with RTNL.

Yeah, I am thinking if we could replace the RTNL lock with a spinlock in
IPv4 multicast, as IPv6 multicast uses its own spin lock too. I don't
see any reason why inet->mc_list has to be protected by RTNL.

> 
> 
> I have been busy with health stuff, so the going is slow.

No problem, take care!
